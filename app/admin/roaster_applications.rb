ActiveAdmin.register RoasterApplication do
  menu parent: "Roasters", priority: 4, label: "Applications"

  # Permit parameters for create/update
  permit_params :email, :roaster_name, :phone_number, :type_of_business, :comment, :status, :full_name, :website_url

  # Index page configuration
  index do
    selectable_column
    id_column
    column "Email" do |application|
      application.email
    end
    column "Roaster Name" do |application|
      application.roaster_name
    end
    column "Full Name" do |application|
      application.full_name
    end
    column :type_of_business
    column :status do |application|
      status_tag application.status
    end
    column :created_at
    actions
  end

  # Filters for the index page
  filter :roaster_name
  filter :email
  filter :type_of_business, as: :select
  filter :status, as: :select, collection: [ "pending", "approved", "rejected" ]
  filter :created_at

  # Show page configuration
  show do
    attributes_table do
      row :id
      row "Email" do |application|
        application.email
      end
      row "Roaster Name" do |application|
        application.roaster_name
      end
      row :type_of_business do |application|
        status_tag application.type_of_business
      end
      row "Comment" do |application|
        application.comment
      end
      row "Website URL" do |application|
        application.website_url
      end
      row :phone_number do |application|
        application.phone_number
      end
      row "Full Name" do |application|
        application.full_name
      end
      row :status do |application|
        status_tag application.status
      end
      row :created_at
      row :updated_at
    end
  end

  # Form configuration
  form do |f|
    f.inputs "Application Details" do
      f.input :email
      f.input :roaster_name
      f.input :full_name
      f.input :phone_number
      f.input :type_of_business, as: :select, collection: RoasterApplication.type_of_businesses.keys
      f.input :comment
      f.input :website_url
      f.input :status, as: :select, collection: [ "pending", "approved", "rejected" ]
    end
    f.actions
  end
end
