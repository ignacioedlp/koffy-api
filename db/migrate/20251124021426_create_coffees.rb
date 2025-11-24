class CreateCoffees < ActiveRecord::Migration[7.2]
  def change
    create_table :coffees do |t|
      t.references :roaster, null: false, foreign_key: true
      
      t.string :name, limit: 100, null: false
      t.text :description
      
      t.string :origin_country, limit: 100
      t.string :varietal, limit: 100
      t.string :process_method, limit: 50
      t.string :roast_level, limit: 50
      t.text :flavor_notes
      
      t.text :image_url
      
      t.boolean :is_active, default: true, null: false
      
      t.timestamps
    end
    
    add_index :coffees, :is_active
    add_index :coffees, :name
    add_index :coffees, :origin_country
    add_index :coffees, :roast_level
  end
end
