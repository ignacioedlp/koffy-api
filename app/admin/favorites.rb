ActiveAdmin.register Favorite do
  menu priority: 8

  permit_params :user_id, :favoritable_type, :favoritable_id

  index do
    selectable_column
    id_column
    column :user
    column :favoritable_type
    column :favoritable_id
    column :favoritable do |favorite|
      if favorite.favoritable.present?
        case favorite.favoritable_type
        when "Coffee"
          link_to favorite.favoritable.name, admin_coffee_path(favorite.favoritable)
        when "Roaster"
          link_to favorite.favoritable.name, admin_roaster_path(favorite.favoritable)
        when "CoffeeVariant"
          link_to "#{favorite.favoritable.coffee.name} - #{favorite.favoritable.grind_type}",
                  admin_coffee_variant_path(favorite.favoritable)
        else
          favorite.favoritable.to_s
        end
      else
        "N/A"
      end
    end
    column :created_at
    actions
  end

  filter :user
  filter :favoritable_type, as: :select, collection: [ "Coffee", "Roaster", "CoffeeVariant" ]
  filter :created_at

  form do |f|
    f.inputs do
      f.input :user
      f.input :favoritable_type, as: :select, collection: [ "Coffee", "Roaster", "CoffeeVariant" ]
      f.input :favoritable_id
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :user
      row :favoritable_type
      row :favoritable_id
      row :favoritable do |favorite|
        if favorite.favoritable.present?
          case favorite.favoritable_type
          when "Coffee"
            link_to favorite.favoritable.name, admin_coffee_path(favorite.favoritable)
          when "Roaster"
            link_to favorite.favoritable.name, admin_roaster_path(favorite.favoritable)
          when "CoffeeVariant"
            link_to "#{favorite.favoritable.coffee.name} - #{favorite.favoritable.grind_type}",
                    admin_coffee_variant_path(favorite.favoritable)
          else
            favorite.favoritable.to_s
          end
        else
          "N/A"
        end
      end
      row :created_at
      row :updated_at
    end
  end
end
