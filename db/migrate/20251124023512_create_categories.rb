class CreateCategories < ActiveRecord::Migration[7.2]
  def change
    create_table :categories do |t|
      t.references :roaster, null: false, foreign_key: true
      t.string :name, limit: 50, null: false
      t.text :description

      t.string :color, limit: 7

      t.string :icon, limit: 50

      t.boolean :is_active, default: true, null: false

      t.integer :position, default: 0, null: false

      t.timestamps
    end

    # Indexes for better performance
    add_index :categories, :is_active
    add_index :categories, :position
    add_index :categories, [ :roaster_id, :name ], unique: true
  end
end
