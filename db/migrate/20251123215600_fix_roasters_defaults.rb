class FixRoastersDefaults < ActiveRecord::Migration[7.2]
  def up
    # Fix roasters table
    execute "ALTER TABLE roasters ALTER COLUMN name SET NOT NULL"
    execute "ALTER TABLE roasters ALTER COLUMN active SET DEFAULT true"
    execute "ALTER TABLE roasters ALTER COLUMN active SET NOT NULL"
    execute "UPDATE roasters SET active = true WHERE active IS NULL"

    # Fix roaster_memberships table
    execute "ALTER TABLE roaster_memberships ALTER COLUMN role SET DEFAULT 'member'"
    execute "ALTER TABLE roaster_memberships ALTER COLUMN role SET NOT NULL"
    execute "UPDATE roaster_memberships SET role = 'member' WHERE role IS NULL"

    execute "ALTER TABLE roaster_memberships ALTER COLUMN active SET DEFAULT true"
    execute "ALTER TABLE roaster_memberships ALTER COLUMN active SET NOT NULL"
    execute "UPDATE roaster_memberships SET active = true WHERE active IS NULL"

    # Add indexes
    execute "CREATE INDEX IF NOT EXISTS index_roasters_on_active ON roasters (active)"
    execute "CREATE INDEX IF NOT EXISTS index_roasters_on_name ON roasters (name)"
    execute "CREATE UNIQUE INDEX IF NOT EXISTS index_roaster_memberships_on_user_and_roaster ON roaster_memberships (user_id, roaster_id)"
    execute "CREATE INDEX IF NOT EXISTS index_roaster_memberships_on_roaster_and_role ON roaster_memberships (roaster_id, role)"
    execute "CREATE INDEX IF NOT EXISTS index_roaster_memberships_on_active ON roaster_memberships (active)"
  end

  def down
    execute "ALTER TABLE roasters ALTER COLUMN name DROP NOT NULL"
    execute "ALTER TABLE roasters ALTER COLUMN active DROP DEFAULT"
    execute "ALTER TABLE roasters ALTER COLUMN active DROP NOT NULL"

    execute "ALTER TABLE roaster_memberships ALTER COLUMN role DROP DEFAULT"
    execute "ALTER TABLE roaster_memberships ALTER COLUMN role DROP NOT NULL"
    execute "ALTER TABLE roaster_memberships ALTER COLUMN active DROP DEFAULT"
    execute "ALTER TABLE roaster_memberships ALTER COLUMN active DROP NOT NULL"

    execute "DROP INDEX IF EXISTS index_roasters_on_active"
    execute "DROP INDEX IF EXISTS index_roasters_on_name"
    execute "DROP INDEX IF EXISTS index_roaster_memberships_on_user_and_roaster"
    execute "DROP INDEX IF EXISTS index_roaster_memberships_on_roaster_and_role"
    execute "DROP INDEX IF EXISTS index_roaster_memberships_on_active"
  end
end
