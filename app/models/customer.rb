class Customer < ApplicationRecord
  belongs_to :client
  has_many :subscriptions

  def newsletter_preferred?
    Rails.cache.read("client-paywall-#{self.client.token}::#{self.email}")
  end

  def draft_newsletter_preference(preference)
    Rails.cache.write(
      "client-paywall-#{self.client.token}::#{self.email}",
      preference,
      { expires_in: 30.minutes }
    )
  end
end
