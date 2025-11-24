ActiveAdmin.register OrderItem do

  menu parent: 'Orders', priority: 1, label: 'Order Items'

  # Permit parameters for create/update
  permit_params :order_id, :coffee_variant_id, :quantity, :unit_price
  
  # Index page configuration
  index do
    selectable_column
    id_column
    
    column :order do |item|
      link_to "Order ##{item.order.id}", admin_order_path(item.order)
    end
    
    column :coffee_variant do |item|
      link_to item.coffee_variant.full_name, admin_coffee_variant_path(item.coffee_variant)
    end
    
    column :coffee do |item|
      link_to item.coffee_variant.coffee.name, admin_coffee_path(item.coffee_variant.coffee)
    end
    
    column :quantity
    
    column :unit_price do |item|
      number_to_currency(item.unit_price, unit: "$")
    end
    
    column "Subtotal" do |item|
      number_to_currency(item.subtotal, unit: "$")
    end
    
    column "Stock Status" do |item|
      if item.sufficient_stock?
        status_tag "#{item.coffee_variant.stock} available", class: 'yes'
      else
        status_tag "Only #{item.coffee_variant.stock} available (needs #{item.quantity})", class: 'no'
      end
    end
    
    column :created_at
    actions
  end
  
  # Filters for the index page
  filter :order, as: :select, collection: -> { Order.order(created_at: :desc).limit(100) }
  filter :coffee_variant, as: :select, collection: -> { CoffeeVariant.includes(:coffee).order('coffees.name') }
  filter :quantity
  filter :unit_price
  filter :created_at
  
  # Show page configuration
  show do
    attributes_table do
      row :id
      
      row :order do |item|
        link_to "Order ##{item.order.id}", admin_order_path(item.order)
      end
      
      row "Order User" do |item|
        link_to item.order.user.email, admin_user_path(item.order.user)
      end
      
      row "Order Roaster" do |item|
        link_to item.order.roaster.name, admin_roaster_path(item.order.roaster)
      end
      
      row "Order Status" do |item|
        status_tag item.order.status.titleize
      end
      
      row :coffee_variant do |item|
        link_to item.coffee_variant.full_name, admin_coffee_variant_path(item.coffee_variant)
      end
      
      row :coffee do |item|
        link_to item.coffee_variant.coffee.name, admin_coffee_path(item.coffee_variant.coffee)
      end
      
      row "Coffee Details" do |item|
        div do
          div "Grind Type: #{item.coffee_variant.grind_type || 'N/A'}"
          div "Bag Size: #{item.coffee_variant.bag_size || 'N/A'}"
          div "Current Price: #{number_to_currency(item.coffee_variant.price, unit: '$')}"
          div "Current Stock: #{item.coffee_variant.stock}"
        end
      end
      
      row :quantity
      
      row :unit_price do |item|
        number_to_currency(item.unit_price, unit: "$")
      end
      
      row "Subtotal" do |item|
        strong number_to_currency(item.subtotal, unit: "$")
      end
      
      row "Stock Check" do |item|
        if item.sufficient_stock?
          status_tag "Sufficient stock available", class: 'yes'
        else
          status_tag "Insufficient stock! Order needs #{item.quantity} but only #{item.coffee_variant.stock} available", class: 'no'
        end
      end
      
      row "Variant Available" do |item|
        status_tag item.variant_available? ? 'Available' : 'Out of Stock', 
                   class: item.variant_available? ? 'yes' : 'no'
      end
      
      row :created_at
      row :updated_at
    end
    
    # Panel showing order details
    panel "Order Summary" do
      attributes_table_for order_item.order do
        row "Order Total" do |order|
          number_to_currency(order.total_amount || order.calculate_total, unit: "$")
        end
        row "Total Items" do |order|
          order.order_items.count
        end
        row "Total Quantity" do |order|
          order.total_quantity
        end
        row :status
        row :pickup_or_delivery
      end
    end
  end
  
  # Form configuration
  form do |f|
    f.inputs "Order Item Details" do
      f.input :order, as: :select, 
              collection: Order.order(created_at: :desc).limit(100).map { |o| 
                ["Order ##{o.id} - #{o.user.email} - #{o.roaster.name} (#{o.status})", o.id] 
              }
      
      f.input :coffee_variant, as: :select, 
              collection: CoffeeVariant.includes(:coffee).order('coffees.name').map { |v| 
                ["#{v.coffee.name} - #{v.bag_size} (#{v.grind_type}) - $#{v.price}", v.id] 
              },
              hint: "Select the coffee variant for this order item"
      
      f.input :quantity, 
              hint: "Number of units ordered"
      
      f.input :unit_price, 
              input_html: { min: 0.01, step: 0.01 },
              hint: "Price per unit at the time of order (minimum $0.01)"
      
      # Show current variant price if editing
      if f.object.coffee_variant.present?
        f.inputs "Current Variant Information" do
          li do
            content_tag :div, style: "padding: 10px; background: #f5f5f5; border-radius: 4px;" do
              "Current Price: #{number_to_currency(f.object.coffee_variant.price, unit: '$')} | " +
              "Stock Available: #{f.object.coffee_variant.stock}"
            end
          end
        end
      end
    end
    
    f.actions
  end
  
  # Before save callback to update order total
  before_save do |item|
    # This will be handled by the model callbacks if needed
  end
end

