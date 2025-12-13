class Subscription < ApplicationRecord
  include Ransackable

  belongs_to :user
  has_many :subscription_items, dependent: :destroy
  has_many :coffee_variants, through: :subscription_items

  accepts_nested_attributes_for :subscription_items, allow_destroy: true

  validates :day_of_month, presence: true, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 28 }
  validates :active, inclusion: { in: [ true, false ] }

  scope :active, -> { where(active: true) }
  scope :due_today, -> {
    where(day_of_month: Time.current.day)
    .where("last_order_created_at IS NULL OR last_order_created_at < ?", Time.current.beginning_of_day)
  }

  def process_order!
    return unless active?
    return if subscription_items.empty?

    # Group items by roaster to create separate orders per roaster
    items_by_roaster = subscription_items.group_by { |item| item.coffee_variant.coffee.roaster }

    Order.transaction do
      items_by_roaster.each do |roaster, items|
        total_amount = items.sum { |item| item.coffee_variant.price * item.quantity }

        order = user.orders.create!(
          roaster: roaster,
          status: "pending",
          total_amount: total_amount,
          pickup_or_delivery: self.pickup_or_delivery
        )

        items.each do |item|
          order.order_items.create!(
            coffee_variant: item.coffee_variant,
            quantity: item.quantity,
            unit_price: item.coffee_variant.price
          )
        end
      end

      update!(last_order_created_at: Time.current)
    end
  end
end
