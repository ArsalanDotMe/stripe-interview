class Transaction < ApplicationRecord
  belongs_to :subscription, optional: true
  belongs_to :customer, optional: true
  belongs_to :client
  belongs_to :purchase, optional: true

  validates_inclusion_of :purpose, :in => %w(charge refund)
  validates_inclusion_of :status, :in => %w(confirmed failed)
end
# TODO each transaction has its own price_id/product_id combo for both zlick and/or stripe so it's probably good to add this external provider specfic product/price id on internal transaction objects.
