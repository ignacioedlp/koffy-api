ActiveAdmin.register Roaster do
  controller do
    def find_resource
      begin
        scoped_collection.where(slug: params[:id]).first!
      rescue ActiveRecord::RecordNotFound
        scoped_collection.find(params[:id])
      end
    end
  end

  # Permit parameters for create/update
  permit_params :name, :location, :description, :active, :delivery_available, :logo, :image, :tags,
                business_hours_attributes: [ :id, :day_of_week, :opens_at, :closes_at, :is_closed, :_destroy ]

  # Member action to remove logo
  member_action :remove_logo, method: :delete do
    if resource.logo.attached?
      resource.logo.purge
      redirect_to admin_roaster_path(resource), notice: "Logo removed successfully"
    else
      redirect_to admin_roaster_path(resource), alert: "No logo found"
    end
  end

  # Index page configuration
  index do
    selectable_column
    id_column
    column :logo do |roaster|
      if roaster.logo.attached?
        image_tag url_for(roaster.logo), size: "80x80"
      else
        "No logo"
      end
    end
    column :image do |roaster|
      if roaster.image.attached?
        image_tag url_for(roaster.image), size: "80x80"
      else
        "No image"
      end
    end
    column :name
    column :slug
    column :location
    column :active do |roaster|
      status_tag roaster.active ? "Active" : "Inactive", class: roaster.active ? "yes" : "no"
    end
    column :delivery_available do |roaster|
      status_tag roaster.delivery_available ? "Available" : "Not Available", class: roaster.delivery_available ? "yes" : "no"
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
  filter :slug
  filter :created_at
  filter :delivery_available
  filter :average_rating

  # Show page configuration
  show do
    attributes_table do
      row :id
      row :name
      row :slug
      row :tags
      row :logo do |roaster|
        if roaster.logo.attached?
          image_tag url_for(roaster.logo), size: "150x150"
        else
          "No logo"
        end
      end
      row :image do |roaster|
        if roaster.image.attached?
          image_tag url_for(roaster.image), size: "150x150"
        else
          "No image"
        end
      end

      row :location
      row :description
      row :active do |roaster|
        status_tag roaster.active ? "Active" : "Inactive", class: roaster.active ? "yes" : "no"
      end
      row :delivery_available do |roaster|
        status_tag roaster.delivery_available ? "Available" : "Not Available", class: roaster.delivery_available ? "yes" : "no"
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

    panel "Coffees" do
      if roaster.coffees.any?
        table_for roaster.coffees.order(created_at: :desc).limit(10) do
          column "Coffee Name" do |coffee|
            link_to coffee.name, admin_coffee_path(coffee)
          end
          column :origin_country
          column :roast_level
          column :is_active do |coffee|
            status_tag coffee.is_active ? "Active" : "Inactive"
          end
          column :total_stock do |coffee|
            coffee.total_stock
          end
        end
        div style: "margin-top: 10px;" do
          link_to "View All Coffees (#{roaster.coffees.count})", admin_coffees_path(q: { roaster_id_eq: roaster.id })
        end
      else
        para "No coffees added yet."
        div do
          link_to "Add First Coffee", new_admin_coffee_path(coffee: { roaster_id: roaster.id }), class: "button"
        end
      end
    end

    panel "Categories" do
      if roaster.categories.any?
        table_for roaster.categories.order(position: :asc) do
          column "Category Name" do |category|
            link_to category.name, admin_category_path(category)
          end
          column :color do |category|
            if category.color.present?
              span style: "background-color: #{category.color}; padding: 5px 15px; color: white; border-radius: 4px;" do
                category.color
              end
            else
              "No color"
            end
          end
          column :position
          column :is_active do |category|
            status_tag category.is_active ? "Active" : "Inactive"
          end
          column :coffees_count do |category|
            category.coffees.count
          end
        end
        div style: "margin-top: 10px;" do
          link_to "View All Categories (#{roaster.categories.count})", admin_categories_path(q: { roaster_id_eq: roaster.id })
        end
      else
        para "No categories created yet."
        div do
          link_to "Add First Category", new_admin_category_path(category: { roaster_id: roaster.id }), class: "button"
        end
      end
    end

    panel "Business Hours" do
      if roaster.business_hours.any?
        table_for roaster.business_hours.ordered_by_day do
          column "Day" do |business_hour|
            business_hour.day_of_week.titleize
          end
          column :opens_at do |business_hour|
            business_hour.opens_at&.strftime("%H:%M") || "-"
          end
          column :closes_at do |business_hour|
            business_hour.closes_at&.strftime("%H:%M") || "-"
          end
          column :is_closed do |business_hour|
            status_tag business_hour.is_closed ? "Closed" : "Open", class: business_hour.is_closed ? "error" : "ok"
          end
        end
        div style: "margin-top: 10px;" do
          para "Edit business hours in the form below."
        end
      else
        para "No business hours configured yet. Add them in the form below."
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
      f.input :slug
      f.input :delivery_available
      f.input :tags, as: :text, hint: "Add tags separated by commas"
      f.input :logo, as: :file, hint: "Upload a logo for the roaster"
      f.input :image, as: :file, hint: "Upload an image for the roaster"

      # Show current logo if editing
      if f.object.logo.attached?
        f.inputs "Current Logo" do
          li do
            content_tag :div, style: "margin: 10px 0; padding: 10px; border: 1px solid #ddd; display: inline-block;" do
              image_tag(url_for(f.object.logo), size: "150x150") +
              content_tag(:br) +
              link_to("Remove Logo", remove_logo_admin_roaster_path(f.object),
                      method: :delete,
                      data: { confirm: "Are you sure you want to remove this logo?" },
                      style: "color: red;")
            end
          end
        end
      end
    end

    f.inputs "Business Hours" do
      f.has_many :business_hours, allow_destroy: true, heading: false do |bh|
        bh.input :day_of_week, as: :select,
                 collection: BusinessHour.day_of_weeks.keys.map { |day| [ day.titleize, day ] },
                 include_blank: "Select a day"
        bh.input :is_closed, label: "Closed all day"
        bh.input :opens_at, as: :time_picker, label: "Opens at"
        bh.input :closes_at, as: :time_picker, label: "Closes at"
      end
    end

    f.actions
  end
end
