module SendgridServices
  class SendCustomerNotification < ApplicationService
    include SendgridVars

    def initialize(recipient, client, rich_content, subject, preheader)
      @rich_content = rich_content
      @subject = subject
      @preheader = preheader
      @recipient = recipient
      @client = client
      @publication_name = publication_name()
      @publisher_email = from_email()
      @http =
        HTTP.headers('Authorization' => "Bearer #{SENDGRID_API_KEY}",
                     'content-type' => 'application/json').accept(:json)
    end

    def call
      logger.info "Sending general notifcation email to #{@recipient}"

      OpenStruct.new({
        success?: true
      })
    end
  end
end
