ActiveAdmin.register Category do
  menu parent: "Roasters", priority: 3

  permit_params :roaster_id, :name, :description, :color, :icon, :is_active, :position

  index do
    selectable_column
    id_column
    column :roaster do |category|
      link_to category.roaster.name, admin_roaster_path(category.roaster)
    end

    column :name

    column :color do |category|
      if category.color.present?
        span style: "background-color: #{category.color}; padding: 5px 15px; color: white; border-radius: 4px;" do
          category.color
        end
      else
        "No color"
      end
    end

    column :icon
    column :position

    column :is_active do |category|
      status_tag category.is_active ? "Active" : "Inactive", class: category.is_active ? "yes" : "no"
    end

    column :coffees_count do |category|
      category.coffees.count
    end

    column :created_at
    actions
  end

  filter :roaster, as: :select, collection: -> { Roaster.order(:name) }
  filter :name
  filter :is_active
  filter :position
  filter :created_at

  show do
    attributes_table do
      row :id

      row :roaster do |category|
        link_to category.roaster.name, admin_roaster_path(category.roaster)
      end

      row :name
      row :description

      row :color do |category|
        if category.color.present?
          span style: "background-color: #{category.color}; padding: 10px 20px; color: white; border-radius: 4px; display: inline-block;" do
            category.color
          end
        else
          "No color assigned"
        end
      end

      row :icon
      row :position

      row :is_active do |category|
        status_tag category.is_active ? "Active" : "Inactive", class: category.is_active ? "yes" : "no"
      end

      row :created_at
      row :updated_at
    end

    panel "Coffees in this Category" do
      if category.coffees.any?
        table_for category.coffees do
          column "Coffee Name" do |coffee|
            link_to coffee.name, admin_coffee_path(coffee)
          end
          column :origin_country
          column :roast_level
          column :is_active do |coffee|
            status_tag coffee.is_active ? "Active" : "Inactive"
          end
          column :featured do |coffee|
            status_tag coffee.featured ? "Featured" : "Regular"
          end
          column :total_stock do |coffee|
            coffee.total_stock
          end
        end
      else
        para "No coffees assigned to this category yet."
      end
    end
  end

  form do |f|
    f.inputs "Category Details" do
      f.input :roaster, as: :select, collection: Roaster.order(:name)

      f.input :name, label: "Category Name"
      f.input :description, as: :text, input_html: { rows: 3 }
      f.input :color, label: "Color (Hex Code)",
              hint: "Enter a hex color code (e.g., #FF5733). This will be used in the app UI."
      f.input :icon, label: "Icon Name",
              hint: "Icon identifier (optional, depends on your app's icon library)"
      f.input :position, label: "Display Position",
              hint: "Lower numbers appear first"
    end

    f.inputs "Status" do
      f.input :is_active, label: "Active"
    end

    f.actions
  end
end
