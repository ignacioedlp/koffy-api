class CreateSubscriptionItems < ActiveRecord::Migration[7.2]
  def change
    create_table :subscription_items do |t|
      t.references :subscription, null: false, foreign_key: true
      t.references :coffee_variant, null: false, foreign_key: true
      t.integer :quantity

      t.timestamps
    end
  end
end
