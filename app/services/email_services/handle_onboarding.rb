module EmailServices
  class HandleOnboarding < ApplicationService
    def initialize(customer, client, payment_provider)
      @customer = customer
      @client = client
      @payment_provider = payment_provider
    end

    def call
      begin
        SendgridServices::SendWelcomeMail.call(@customer.email, @client, @payment_provider)
        unless @client.contact_list_present?
          create_list_result = SendgridServices::CreateList.call(@client.token)
          @client.update!(sendgrid_contact_list_id: create_list_result.payload.id)
        end
        if @customer.newsletter_preferred?
          SendgridServices::AddContact.call(@customer.email, @client.sendgrid_contact_list_id)
        end
        OpenStruct.new({ success?: true })
      rescue => e
        logger.error e
        OpenStruct.new({ success?: false, error: e })
      end
    end
  end
end
