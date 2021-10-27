module SendgridServices
  class SendWelcomeMail < ApplicationService
    include SendgridVars
    include MoneyFunctions

    def initialize(recipient, client, payment_provider)
      @payment_provider = payment_provider
      @recipient = recipient
      @client = client
      @publication_name = publication_name
      @price = get_formatted_price(@client.subscription_price(), @client.currency)
      @http =
        HTTP.headers('Authorization' => "Bearer #{SENDGRID_API_KEY}", 'content-type' => 'application/json').accept(:json)
    end

    def call
      logger.info "Sending welcome email to #{@recipient}"
      OpenStruct.new({ success?: true })
    end
  end
end
