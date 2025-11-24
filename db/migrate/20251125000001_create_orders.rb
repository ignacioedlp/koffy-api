class CreateOrders < ActiveRecord::Migration[7.2]
  def change
    create_table :orders do |t|
      # Foreign keys
      t.references :user, null: false, foreign_key: true
      t.references :roaster, null: false, foreign_key: true

      # Order details
      t.string :status, limit: 30, default: 'pending', null: false
      t.decimal :total_amount, precision: 10, scale: 2
      t.string :pickup_or_delivery, limit: 20
      t.text :qr_code_data

      # Timestamps
      t.timestamps
    end

    # Indexes for better query performance
    # Note: user_id and roaster_id indexes are automatically created by t.references
    add_index :orders, :status
    add_index :orders, :created_at
  end
end
