class Order < ApplicationRecord
  # Include Ransackable concern for ActiveAdmin search functionality
  include Ransackable

  # Associations
  # An order belongs to a user (the customer)
  belongs_to :user

  # An order belongs to a roaster (the seller)
  belongs_to :roaster

  # An order has many order items (the products in the order)
  has_many :order_items, dependent: :destroy

  # An order has many coffee variants through order items
  has_many :coffee_variants, through: :order_items

  # Accept nested attributes for order items (allows creating items from order form)
  accepts_nested_attributes_for :order_items, allow_destroy: true, reject_if: :all_blank

  # Validations
  validates :status, presence: true, length: { maximum: 30 }
  validates :status, inclusion: {
    in: [ "pending", "confirmed", "preparing", "ready", "completed", "cancelled" ],
    message: "%{value} is not a valid status"
  }
  validates :total_amount, numericality: { greater_than_or_equal_to: 0 }, allow_blank: true
  validates :pickup_or_delivery, inclusion: {
    in: [ "pickup", "delivery" ],
    message: "%{value} must be either 'pickup' or 'delivery'"
  }, allow_blank: true

  # Scopes
  # Scope to find orders by status
  scope :by_status, ->(status) { where(status: status) }

  # Scope to find pending orders
  scope :pending, -> { where(status: "pending") }

  # Scope to find confirmed orders
  scope :confirmed, -> { where(status: "confirmed") }

  # Scope to find preparing orders
  scope :preparing, -> { where(status: "preparing") }

  # Scope to find ready orders
  scope :ready, -> { where(status: "ready") }

  # Scope to find completed orders
  scope :completed, -> { where(status: "completed") }

  # Scope to find cancelled orders
  scope :cancelled, -> { where(status: "cancelled") }

  # Scope to find recent orders (newest first)
  scope :recent, -> { order(created_at: :desc) }

  # Scope to find orders by user
  scope :by_user, ->(user_id) { where(user_id: user_id) }

  # Scope to find orders by roaster
  scope :by_roaster, ->(roaster_id) { where(roaster_id: roaster_id) }

  # Scope to find orders by QR code
  scope :by_qr_code, ->(qr_code) { where(qr_code_data: qr_code) }

  # Callback to generate QR code before creating the order
  before_create :generate_qr_code

  # Instance methods

  # Calculate total amount from order items
  def calculate_total
    order_items.sum { |item| item.quantity * item.unit_price }
  end

  # Update total amount based on order items
  def update_total!
    update(total_amount: calculate_total)
  end

  # Check if order can be cancelled
  def can_cancel?
    [ "pending", "confirmed" ].include?(status)
  end

  # Cancel the order
  def cancel!
    if can_cancel?
      update(status: "cancelled")
    else
      errors.add(:status, "cannot cancel order with status #{status}")
      false
    end
  end

  # Check if order is completed
  def completed?
    status == "completed"
  end

  # Check if order is pending
  def pending?
    status == "pending"
  end

  # Check if order is cancelled
  def cancelled?
    status == "cancelled"
  end

  # Get total quantity of items in the order
  def total_quantity
    order_items.sum(:quantity)
  end

  # Callback to update total amount after order items are saved
  after_save :update_total_if_needed

  # Validate stock availability before confirming order
  validate :validate_stock_availability, if: -> { status == "confirmed" && status_changed? }

  # Callback to handle stock when order status changes
  after_update :handle_stock_on_status_change, if: :saved_change_to_status?

  private

  # Generate a unique QR code for the order
  # This code will be used to scan and confirm the order when picking up/delivering
  # Called automatically before creating the order (via before_create callback)
  def generate_qr_code
    # Generate a unique code using SecureRandom
    # Format: ORDER-{timestamp}-{random_string}
    # This ensures uniqueness and makes it easy to identify as an order code
    loop do
      timestamp = Time.now.to_i
      random_string = SecureRandom.hex(8).upcase
      self.qr_code_data = "ORDER-#{timestamp}-#{random_string}"

      # Ensure uniqueness by checking if code already exists
      # Skip validation for new records to avoid querying the database
      break unless Order.where(qr_code_data: self.qr_code_data).where.not(id: id).exists?
    end
  end

  def update_total_if_needed
    # Update total amount from order items if there are any items
    if order_items.any?
      calculated_total = calculate_total
      if total_amount.nil? || (total_amount != calculated_total)
        update_column(:total_amount, calculated_total)
      end
    end
  end

  def handle_stock_on_status_change
    previous_status = status_before_last_save

    # When order is confirmed, decrement stock
    if status == "confirmed" && previous_status != "confirmed"
      decrement_stock
    end

    # When order is cancelled and was previously confirmed, restore stock
    if status == "cancelled" && previous_status == "confirmed"
      restore_stock
    end
  end

  def decrement_stock
    order_items.includes(:coffee_variant).each do |item|
      variant = item.coffee_variant
      # Reload variant to get latest stock
      variant.reload
      if variant.stock >= item.quantity
        variant.reduce_stock(item.quantity)
      else
        # This shouldn't happen if validation worked, but handle it gracefully
        Rails.logger.error("Stock decrement failed for order #{id}, item #{item.id}: insufficient stock")
      end
    end
  end

  def restore_stock
    order_items.includes(:coffee_variant).each do |item|
      variant = item.coffee_variant
      variant.add_stock(item.quantity)
    end
  end

  def validate_stock_availability
    order_items.includes(:coffee_variant).each do |item|
      unless item.sufficient_stock?
        errors.add(:base, "Insufficient stock for #{item.coffee_variant.full_name}. Available: #{item.coffee_variant.stock}, Required: #{item.quantity}")
      end
    end
  end
end
