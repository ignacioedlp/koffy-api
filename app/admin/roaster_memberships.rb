ActiveAdmin.register RoasterMembership do
  menu parent: 'Roasters', priority: 2, label: 'Memberships'

  # Permit parameters for create/update
  permit_params :user_id, :roaster_id, :role, :active, :salary, :currency, :salary_period
  
  # Index page configuration
  index do
    selectable_column
    id_column
    column "User" do |membership|
      link_to membership.user.email, admin_user_path(membership.user)
    end
    column "Roaster" do |membership|
      link_to membership.roaster.name, admin_roaster_path(membership.roaster)
    end
    column :role do |membership|
      status_tag membership.role
    end
    column "Salary" do |membership|
      membership.formatted_salary
    end
    column :active do |membership|
      status_tag membership.active ? 'Active' : 'Inactive', class: membership.active ? 'yes' : 'no'
    end
    column :created_at
    actions
  end
  
  # Filters for the index page
  filter :user
  filter :roaster
  filter :role, as: :select, collection: RoasterMembership.roles.keys
  filter :active
  filter :created_at
  
  # Show page configuration
  show do
    attributes_table do
      row :id
      row "User" do |membership|
        link_to membership.user.email, admin_user_path(membership.user)
      end
      row "Roaster" do |membership|
        link_to membership.roaster.name, admin_roaster_path(membership.roaster)
      end
      row :role do |membership|
        status_tag membership.role
      end
      row "Salary" do |membership|
        membership.formatted_salary
      end
      row "Annual Salary" do |membership|
        membership.annual_salary ? "#{membership.currency_symbol}#{membership.annual_salary.round(2)}" : "N/A"
      end
      row :currency
      row :active do |membership|
        status_tag membership.active ? 'Active' : 'Inactive', class: membership.active ? 'yes' : 'no'
      end
      row :created_at
      row :updated_at
    end
  end
  
  # Form configuration
  form do |f|
    f.inputs "Membership Details" do
      f.input :user, as: :select, collection: User.all.map { |u| [u.email, u.id] }
      f.input :roaster, as: :select, collection: Roaster.all.map { |r| [r.name, r.id] }
      f.input :role, as: :select, collection: RoasterMembership.roles.keys
      f.input :salary, as: :number, step: 0.01, hint: "Salary amount"
      f.input :salary_period, as: :select, collection: RoasterMembership.salary_periods.keys, hint: "How often is this salary paid?"
      f.input :currency, as: :select, collection: %w[USD EUR COP ARS MXN CLP PEN], hint: "Currency for the salary"
      f.input :active
    end
    f.actions
  end
end
