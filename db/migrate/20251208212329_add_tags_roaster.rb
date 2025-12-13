class AddTagsRoaster < ActiveRecord::Migration[7.2]
  def change
    add_column :roasters, :tags, :text
  end
end
