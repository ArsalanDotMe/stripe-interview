class Client < ApplicationRecord
  include MoneyFunctions

  has_many :customers
  has_many :subscriptions
  has_many :purchases
  has_many :price_plans
  has_one :mail_sender

  validates :name, presence: true

  after_initialize do |client|
    client.token ||= SecureRandom.hex
    client.secret ||= SecureRandom.hex
    # TODO remove this logic to fetch product ids from this hash, migrate all data to not contain this value.
    # Do this once all clients move to new logic introduced with different pricing for each month
    client.payment_credentials ||= {
      # Zlick integeration adds "domain" key, with value provided by Zlick.
      "connect": {
        "account_id": nil,
        "details_submitted": false
      },

      "subs": {
        # Stripe integeration adds "price_id" & "product_id" in respective modes hash.
        # Zlick integeration adds key "zlick_product_id" in respective modes hash. Value of this key is provided by Zlick.
        "sandbox": {},
        "live": {}
      }
    }
  end

  def active_price_plan
    return nil unless self.active_price_plan_id

    self.price_plans.find(self.active_price_plan_id)
  end

  def phone_payments_profile_submitted?
    company_registration_number.present?
  end

  def stripe_connected?
    payment_credentials["connect"]["details_submitted"].present?
  end

  def is_live?
    live_mode.present?
  end

  def applepay_enabled?
    applepay_enabled.present?
  end

  def active_article_price_in_unit
    get_decimal_from_unit_amount(self.currency, self.active_article_price)
  end

  def phone_payments_enabled?
    self.phone_payments_enabled
  end

  def googlepay_enabled?
    googlepay_enabled.present?
  end

  def contact_list_present?
    sendgrid_contact_list_id.present?
  end

  def send_subs_notifications?
    subscription_notifications
  end

  def active_article_price
    is_live? ? self[:article_price] : self[:test_article_price]
  end

  def active_article_price_formatted
    get_formatted_price(self.active_article_price, self.currency)
  end

  def subscription_price
    if self.active_price_plan_id
      self.active_price_plan&.price_steps&.last&.amount
    else
      self[:subscription_price]
    end
  end

  def subscription_first_price
    self.active_price_plan&.price_steps&.first&.amount
  end

  def subscription_price_formatted
    get_formatted_price(self.subscription_price, self.currency)
  end

  def subscription_first_price_formatted
    get_formatted_price(self.subscription_first_price, self.currency)
  end

  def subscription_name
    if self.active_price_plan_id
      self.active_price_plan&.name
    else
      self[:subscription_name]
    end
  end

  def set_active_price_plan_id(id)
    if is_live?
      self.live_active_price_plan_id = id
    else
      self.test_active_price_plan_id = id
    end
  end

  def active_price_plan_id
    if is_live?
      self.live_active_price_plan_id
    else
      self.test_active_price_plan_id
    end
  end
end
