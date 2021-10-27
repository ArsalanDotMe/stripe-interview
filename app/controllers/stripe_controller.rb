class StripeController < ApplicationController
  SUBSCRIPTION_PAYMENT_SUCCESS_EVENT = ['invoice.paid']

  def webhook
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    logger.info "stripe webhook received"

    event = nil

    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, @endpoint_secret
      )
    rescue JSON::ParserError => e
      # Invalid payload
      logger.error e
      return render json: { message: e }, status: 400
    rescue Stripe::SignatureVerificationError => e
      # Invalid signature
      logger.error e
      return render json: { message: e }, status: 400
    end

    if SUBSCRIPTION_PAYMENT_SUCCESS_EVENT.include? event.type
      # Customer is charged successfully either recurring or first time.
      # Now update the state of the paywall subscription
      invoice = event.data.object # Stripe::Invoice
      if invoice.subscription.nil?
        logger.warn "Invoice event has missing subscription"
        return render json: {}, status: 200
      end
      stripe_subs = nil
      invoice.lines.data.each { |item|
        if item.type == 'subscription'
          stripe_subs = item
        end
      }

      logger.info "#{stripe_subs.subscription} Subscription attached with invoice.paid event"

      subs = Subscription.find_by(
        provider_subscription_id: stripe_subs.subscription
      )

      customer_id = subs.customer_id
      client = subs.client
      order_reference = subs.order_reference
      customer = subs.customer

      transaction = Transaction.new({
        subscription_id: subs.id,
        client_id: client.id,
        customer_id: customer_id,
        purpose: 'charge',
        status: 'confirmed',
        amount_cents: invoice.amount_paid&.to_i,
        amount_currency: client.currency,
        live_mode: client.live_mode,
        provider_response: invoice.to_hash
      })

      if subs.state == 'initial'
        # new subs
        logger.info "#{order_reference} Confirming subscription for #{customer_id}"

        client = subs.client    

        EmailServices::HandleOnboarding.call(customer, client, 'stripe')

        logger.info "Updating subscription with confirmation provider response"
        transaction.save!
        subs.update!(
          price: invoice.amount_paid&.to_i,
          invoiced_at: DateTime.current.to_time,
          state: 'active', # stripe_subs.status is also in 'active' status here.
          expires_at: Time.at(stripe_subs.period.end).to_datetime + 2.days
        )
        # Send subscription started notification
        if client.send_subs_notifications?
          SendgridServices::SendSubscriptionNotificationMail.call(
            subs,
            'You have a new subscriber.',
            'New subscription'
          )
        end
      else
        # recurring subs
        logger.info "#{order_reference} Renewing existing subscription for #{customer_id}"
        transaction.save!
        subs.update!(
          state: 'active',
          expires_at: (Time.at(stripe_subs.period.end).to_datetime + 2.days),
          invoiced_at: DateTime.current.to_time,
          price: invoice.amount_paid&.to_i
        )
        # Handle mails to send if the payment is successful after retries
        SubscriptionServices::StripeSubscriptionCycleSuccessPaymentNotificationManager.call(invoice, client, subs, customer.email)
      end
    else
      logger.warn "Unhandled event type: #{event.type}"
    end
    render json: {}, status: 200
  end
end