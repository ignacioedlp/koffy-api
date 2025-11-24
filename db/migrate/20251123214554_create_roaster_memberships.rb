class CreateRoasterMemberships < ActiveRecord::Migration[7.2]
  def change
    create_table :roaster_memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :roaster, null: false, foreign_key: true
      t.string :role, null: false, default: 'member'
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    # Unique index to prevent duplicate memberships
    # A user can only have one membership per roaster
    add_index :roaster_memberships, [ :user_id, :roaster_id ], unique: true

    # Index for finding all members of a roaster with a specific role
    add_index :roaster_memberships, [ :roaster_id, :role ]

    # Index for finding active memberships
    add_index :roaster_memberships, :active
  end
end
