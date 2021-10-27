module SendgridServices
  class SendSubscriptionNotificationMail < ApplicationService
    include SendgridVars

    def initialize(subs, reason, subject)
      @subs = subs
      @client = subs.client
      @user = user
      @customer = subs.customer
      @appearance_data = OpenStruct.new @client.appearance_data
      @reason = reason
      @subject = subject
      @http =
        HTTP.headers('Authorization' => "Bearer #{SENDGRID_API_KEY}",
                     'content-type' => 'application/json').accept(:json)
    end

    def call
      OpenStruct.new({
        success?: true
      })
    end
  end
end
