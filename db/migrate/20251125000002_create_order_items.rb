class CreateOrderItems < ActiveRecord::Migration[7.2]
  def change
    create_table :order_items do |t|
      # Foreign keys
      t.references :order, null: false, foreign_key: true
      t.references :coffee_variant, null: false, foreign_key: true

      # Item details
      t.integer :quantity
      t.decimal :unit_price, precision: 10, scale: 2
    end

    # Note: order_id and coffee_variant_id indexes are automatically created by t.references
  end
end
