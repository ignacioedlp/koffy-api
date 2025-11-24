class CreateRoasters < ActiveRecord::Migration[7.2]
  def change
    create_table :roasters do |t|
      t.string :name, null: false
      t.string :location
      t.text :description
      t.text :logo_url
      t.numeric :average_rating, default: 0, null: false
      t.boolean :delivery_available, default: false, null: false
      t.boolean :active, default: true, null: false

      t.timestamps
    end
    
    # Index for faster queries on active roasters
    add_index :roasters, :active
    # Index for searching by name
    add_index :roasters, :name
    # Index for searching by delivery availability
    add_index :roasters, :delivery_available
  end
end
