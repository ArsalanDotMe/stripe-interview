class Purchase < ApplicationRecord
  belongs_to :client

  has_one :attached_transaction, class_name: 'Transaction'

  validates_inclusion_of :state, in: %w(confirmed refunded failed)

  def transaction
    self.transaction
  end
end
