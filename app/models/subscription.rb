class Subscription < ApplicationRecord
  belongs_to :customer
  belongs_to :client
  has_many :transactions

  enum state: { inactive: 'inactive', active: 'active', ended: 'ended', initial: 'initial', canceled: 'canceled' }
end
