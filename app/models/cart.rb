class Cart < ApplicationRecord
  include Ransackable

  belongs_to :user
  has_many :cart_items, dependent: :destroy
  has_many :coffee_variants, through: :cart_items

  def total_price
    cart_items.sum(&:total_price)
  end

  def total_items
    cart_items.sum(:quantity)
  end
end
