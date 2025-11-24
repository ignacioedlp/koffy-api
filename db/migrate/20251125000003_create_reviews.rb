class CreateReviews < ActiveRecord::Migration[7.2]
  def change
    create_table :reviews do |t|
      # Foreign keys
      t.references :user, null: false, foreign_key: true
      t.references :roaster, null: false, foreign_key: true

      # Review details
      t.decimal :rating, precision: 3, scale: 2, null: false
      t.text :comment

      # Timestamps
      t.timestamps
    end

    # Indexes for better query performance
    # Note: user_id and roaster_id indexes are automatically created by t.references
    add_index :reviews, :rating
    add_index :reviews, :created_at
    # Ensure a user can only review a roaster once
    add_index :reviews, [ :user_id, :roaster_id ], unique: true
  end
end
