class CreateCoffeeVariants < ActiveRecord::Migration[7.2]
  def change
    create_table :coffee_variants do |t|
      t.references :coffee, null: false, foreign_key: true
      t.string :grind_type, limit: 50
      t.string :bag_size, limit: 20

      t.decimal :price, precision: 10, scale: 2, null: false
      t.integer :stock, default: 0, null: false

      t.timestamps
    end

    add_index :coffee_variants, :grind_type
    add_index :coffee_variants, :bag_size
    add_index :coffee_variants, :price
    add_index :coffee_variants, :stock
  end
end
