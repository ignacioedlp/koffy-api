class CartItem < ApplicationRecord
  include Ransackable

  belongs_to :cart
  belongs_to :coffee_variant

  validates :quantity, presence: true, numericality: { greater_than: 0, only_integer: true }

  def total_price
    quantity * coffee_variant.price
  end
end
