class AddSlugToRoasters < ActiveRecord::Migration[7.2]
  def change
    add_column :roasters, :slug, :string
    add_index :roasters, :slug, unique: true
  end
end
