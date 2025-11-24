class CreateCoffeeCategories < ActiveRecord::Migration[7.2]
  def change
    create_table :coffee_categories do |t|
      t.references :coffee, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end

    add_index :coffee_categories, [ :coffee_id, :category_id ], unique: true
  end
end
