ActiveAdmin.register Roaster do
  # Permit parameters for create/update
  permit_params :name, :location, :description, :active, :delivery_available
  
  # Index page configuration
  index do
    selectable_column
    id_column
    column :name
    column :location
    column :active do |roaster|
      status_tag roaster.active ? 'Active' : 'Inactive', class: roaster.active ? 'yes' : 'no'
    end
    column :delivery_available do |roaster|
      status_tag roaster.delivery_available ? 'Available' : 'Not Available', class: roaster.delivery_available ? 'yes' : 'no'
    end
    column :average_rating do |roaster|
      roaster.average_rating
    end
    column :members_count do |roaster|
      roaster.roaster_memberships.active.count
    end
    column :owners do |roaster|
      roaster.owners.count
    end
    column :created_at
    actions
  end
  
  # Filters for the index page
  filter :name
  filter :location
  filter :active
  filter :created_at
  filter :delivery_available
  filter :average_rating
  
  # Show page configuration
  show do
    attributes_table do
      row :id
      row :name
      row :location
      row :description
      row :active do |roaster|
        status_tag roaster.active ? 'Active' : 'Inactive', class: roaster.active ? 'yes' : 'no'
      end
      row :delivery_available do |roaster|
        status_tag roaster.delivery_available ? 'Available' : 'Not Available', class: roaster.delivery_available ? 'yes' : 'no'
      end
      row :average_rating do |roaster|
        roaster.average_rating
      end
      row :created_at
      row :updated_at
    end
    
    panel "Members" do
      table_for roaster.roaster_memberships.includes(:user).active do
        column "User" do |membership|
          link_to membership.user.email, admin_user_path(membership.user)
        end
        column :role do |membership|
          status_tag membership.role
        end
        column "Joined At" do |membership|
          membership.created_at.strftime("%Y-%m-%d %H:%M")
        end
      end
    end
  end
  
  # Form configuration
  form do |f|
    f.inputs "Roaster Details" do
      f.input :name
      f.input :location
      f.input :description, as: :text
      f.input :active
      f.input :delivery_available
    end
    f.actions
  end
end
