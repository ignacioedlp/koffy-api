class OrderItem < ApplicationRecord
  # Include Ransackable concern for ActiveAdmin search functionality
  include Ransackable
  
  # Associations
  # An order item belongs to an order
  belongs_to :order
  
  # An order item belongs to a coffee variant (the product)
  belongs_to :coffee_variant
  
  # Validations
  validates :quantity, presence: true, numericality: { 
    greater_than: 0, 
    only_integer: true 
  }
  validates :unit_price, presence: true, numericality: { 
    greater_than_or_equal_to: 0.01 
  }
  
  # Scopes
  # Scope to find items by order
  scope :by_order, ->(order_id) { where(order_id: order_id) }
  
  # Scope to find items by coffee variant
  scope :by_coffee_variant, ->(variant_id) { where(coffee_variant_id: variant_id) }
  
  # Instance methods
  
  # Calculate subtotal for this item (quantity * unit_price)
  def subtotal
    quantity * unit_price
  end
  
  # Check if the coffee variant is still available
  def variant_available?
    coffee_variant.available?
  end
  
  # Check if there's enough stock for this item
  def sufficient_stock?
    coffee_variant.stock >= quantity
  end
  
  # Callback to set unit_price from variant if not provided
  before_validation :set_unit_price_from_variant, if: -> { unit_price.blank? && coffee_variant.present? }
  
  private
  
  def set_unit_price_from_variant
    self.unit_price = coffee_variant.price if coffee_variant.present?
  end
end

