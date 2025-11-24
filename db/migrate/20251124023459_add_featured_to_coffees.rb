class AddFeaturedToCoffees < ActiveRecord::Migration[7.2]
  def change
    # Add featured flag to highlight special coffees
    # Featured coffees can be displayed prominently on the homepage
    add_column :coffees, :featured, :boolean, default: false, null: false
    
    # Add index for faster queries of featured coffees
    add_index :coffees, :featured
  end
end
