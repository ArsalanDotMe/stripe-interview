module SubscriptionServices
  class HandleStripeSubscriptionBillingCycleFailedPayment < ApplicationService
    def initialize(event)
      @event = event
    end

    def call
      invoice = @event.data.object # Stripe::Invoice
      if invoice.subscription.nil?
        msg = "Invoice event has missing subscription"
        logger.warn msg
        return OpenStruct.new({
          success?: false,
          payload: OpenStruct.new({
            msg: msg
          })
        })
      end

      unless invoice.billing_reason == "subscription_cycle"
        msg = "Customer is onsession failure"
        logger.warn msg
        return OpenStruct.new({
          success?: false,
          payload: OpenStruct.new({
            msg: msg
          })
        })
      end

      # Finding subscription line item on the invoice
      stripe_subs = nil
      invoice.lines.data.each { |item|
        if item.type == 'subscription'
          stripe_subs = item
        end
      }

      logger.info "#{stripe_subs.subscription} Subscription attached with invoice.payment_failed event"

      subs = Subscription.find_by(
        provider_subscription_id: stripe_subs.subscription
      )

      customer = subs.customer
      client = subs.client

      SubscriptionServices::StripeSubscriptionCycleFailedPaymentNotificationManager.call(invoice, client, subs, customer.email)
    end
  end
end

