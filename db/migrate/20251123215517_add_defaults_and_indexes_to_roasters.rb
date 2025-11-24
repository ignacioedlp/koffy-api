class AddDefaultsAndIndexesToRoasters < ActiveRecord::Migration[7.2]
  def change
    # Add defaults and constraints to roasters
    change_column_default :roasters, :active, from: nil, to: true
    change_column_null :roasters, :active, false, true
    change_column_null :roasters, :name, false

    # Add defaults and constraints to roaster_memberships
    change_column_default :roaster_memberships, :role, from: nil, to: 'member'
    change_column_default :roaster_memberships, :active, from: nil, to: true
    change_column_null :roaster_memberships, :role, false, 'member'
    change_column_null :roaster_memberships, :active, false, true

    # Add missing indexes to roasters
    add_index :roasters, :active, if_not_exists: true
    add_index :roasters, :name, if_not_exists: true

    # Add missing indexes to roaster_memberships
    add_index :roaster_memberships, [ :user_id, :roaster_id ], unique: true, if_not_exists: true
    add_index :roaster_memberships, [ :roaster_id, :role ], if_not_exists: true
    add_index :roaster_memberships, :active, if_not_exists: true
  end
end
