module SendgridServices
  module SendgridVars
    extend ActiveSupport::Concern

    API_BASE = 'https://api.sendgrid.com/v3'
    PINCODE_TEMPLATE_ID = ENV.fetch('PINCODE_TEMPLATE_ID')
    WELCOME_TEMPLATE_ID = ENV.fetch('WELCOME_TEMPLATE_ID')
    SUBSCRIPTION_NOTIFICATION_TEMPLATE_ID = ENV.fetch('SUBSCRIPTION_NOTIFICATION_TEMPLATE_ID')
    SENDGRID_API_KEY = ENV.fetch('SENDGRID_API_KEY')
    DEFAULT_VERIFIED_SENDER_ID = ENV.fetch('DEFAULT_VERIFIED_SENDER_ID').to_i
    DEFAULT_SENDER = OpenStruct.new({
      email: ENV.fetch('MAIL_FROM_NOREPLY'),
      name: ENV.fetch('DEFAULT_SENDER_NAME'),
      address: ENV.fetch('DEFAULT_SENDER_ADDRESS'),
      city: ENV.fetch('DEFAULT_SENDER_CITY'),
      country: ENV.fetch('DEFAULT_SENDER_COUNTRY')
    })
  end
end
