ActiveAdmin.register CartItem do
  menu parent: "Carts"

  permit_params :cart_id, :coffee_variant_id, :quantity

  index do
    selectable_column
    id_column
    column :cart
    column :coffee_variant
    column :quantity
    column :total_price do |item|
      number_to_currency(item.total_price)
    end
    column :created_at
    actions
  end

  filter :cart
  filter :coffee_variant
  filter :quantity
  filter :created_at

  form do |f|
    f.inputs do
      f.input :cart
      f.input :coffee_variant
      f.input :quantity
    end
    f.actions
  end
end
