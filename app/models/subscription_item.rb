class SubscriptionItem < ApplicationRecord
  belongs_to :subscription
  belongs_to :coffee_variant

  validates :quantity, presence: true, numericality: { greater_than: 0 }
end
