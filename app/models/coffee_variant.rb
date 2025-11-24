class CoffeeVariant < ApplicationRecord
  include Ransackable
  
  belongs_to :coffee
  
  # A coffee variant can be in many order items
  has_many :order_items, dependent: :destroy
  
  # A coffee variant has many orders through order items
  has_many :orders, through: :order_items
  
  validates :grind_type, length: { maximum: 50 }, allow_blank: true
  
  validates :bag_size, length: { maximum: 20 }, allow_blank: true
  
  validates :price, presence: true, numericality: { greater_than: 0 }
  
  validates :stock, presence: true, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  
  validates :grind_type, uniqueness: { scope: [:coffee_id, :bag_size], 
                                       message: "and bag size combination already exists for this coffee" }
  
  scope :in_stock, -> { where("stock > 0") }
  
  scope :out_of_stock, -> { where(stock: 0) }
  
  scope :by_price_asc, -> { order(price: :asc) }
  
  scope :by_price_desc, -> { order(price: :desc) }
  
  scope :by_stock, -> { order(stock: :desc) }
  
  scope :grind_type_filter, ->(type) { where(grind_type: type) }
  
  scope :bag_size_filter, ->(size) { where(bag_size: size) }
  
  def available?
    stock > 0
  end
  
  def add_stock(quantity)
    self.stock += quantity
    save
  end
  
  def reduce_stock(quantity)
    if quantity <= stock
      self.stock -= quantity
      save
    else
      errors.add(:stock, "insufficient stock available")
      false
    end
  end
  
  def full_name
    parts = []
    parts << coffee.name
    parts << bag_size if bag_size.present?
    parts << "(#{grind_type})" if grind_type.present?
    parts.join(" ")
  end
end
