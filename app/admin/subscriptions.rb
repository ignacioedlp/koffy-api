ActiveAdmin.register Subscription do
  permit_params :user_id, :day_of_month, :active, :last_order_created_at, :name, :pickup_or_delivery,
                subscription_items_attributes: [ :id, :coffee_variant_id, :quantity, :_destroy ]

  scope :all, default: true
  scope :active

  index do
    selectable_column
    id_column
    column :user
    column :day_of_month
    column :active
    column :last_order_created_at
    column :created_at
    column :name
    column :pickup_or_delivery
    column "Items" do |subscription|
      subscription.subscription_items.count
    end
    actions
  end

  filter :user
  filter :day_of_month
  filter :active
  filter :created_at
  filter :pickup_or_delivery

  show do
    attributes_table do
      row :id
      row :user
      row :day_of_month
      row :active
      row :last_order_created_at
      row :created_at
      row :updated_at
      row :name
      row :pickup_or_delivery
    end

    panel "Items" do
      table_for subscription.subscription_items do
        column :coffee_variant
        column :quantity
        column "Price" do |item|
          number_to_currency item.coffee_variant.price
        end
        column "Total" do |item|
          number_to_currency(item.coffee_variant.price * item.quantity)
        end
      end
    end
  end

  form do |f|
    f.inputs "Subscription Details" do
      f.input :user
      f.input :day_of_month, as: :number, min: 1, max: 28
      f.input :active
      f.input :name
      f.input :pickup_or_delivery, as: :select, collection: [ "pickup", "delivery" ], include_blank: false
      f.input :last_order_created_at, as: :datepicker
    end

    f.inputs "Items" do
      f.has_many :subscription_items, allow_destroy: true, new_record: true do |item|
        item.input :coffee_variant
        item.input :quantity
      end
    end
    f.actions
  end
end
