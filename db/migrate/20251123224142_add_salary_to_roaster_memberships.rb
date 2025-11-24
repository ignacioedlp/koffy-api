class AddSalaryToRoasterMemberships < ActiveRecord::Migration[7.2]
  def change
    # Add salary column with precision for monetary values
    # precision: 10 allows values up to 99,999,999.99
    # scale: 2 allows two decimal places (cents)
    add_column :roaster_memberships, :salary, :decimal, precision: 10, scale: 2

    # Optional: Add currency column to support multiple currencies
    add_column :roaster_memberships, :currency, :string, default: 'USD', null: false

    # Add index for salary queries (e.g., finding high earners)
    add_index :roaster_memberships, :salary
  end
end
