class CreateSubscriptions < ActiveRecord::Migration[7.2]
  def change
    create_table :subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :day_of_month
      t.boolean :active
      t.datetime :last_order_created_at
      t.string :name
      t.string :pickup_or_delivery, default: 'delivery'

      t.timestamps
    end
  end
end
