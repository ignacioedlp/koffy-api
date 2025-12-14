ActiveAdmin.register Cart do
  menu priority: 4

  permit_params :user_id

  index do
    selectable_column
    id_column
    column :user
    column :total_items
    column :total_price do |cart|
      number_to_currency(cart.total_price)
    end
    column :created_at
    actions
  end

  filter :user
  filter :created_at

  show do
    attributes_table do
      row :id
      row :user
      row :total_items
      row :total_price do |cart|
        number_to_currency(cart.total_price)
      end
      row :created_at
      row :updated_at
    end

    panel "Cart Items" do
      table_for cart.cart_items do
        column :coffee_variant
        column :quantity
        column :total_price do |item|
          number_to_currency(item.total_price)
        end
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :user
    end
    f.actions
  end
end
