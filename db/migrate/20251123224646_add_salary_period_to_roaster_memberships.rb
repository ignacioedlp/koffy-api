class AddSalaryPeriodToRoasterMemberships < ActiveRecord::Migration[7.2]
  def change
    # Add salary_period column with default 'monthly'
    # This indicates how often the salary is paid
    add_column :roaster_memberships, :salary_period, :string, default: 'monthly', null: false

    # Add index for querying by salary period
    add_index :roaster_memberships, :salary_period
  end
end
