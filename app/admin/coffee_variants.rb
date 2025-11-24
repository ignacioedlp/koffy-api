ActiveAdmin.register CoffeeVariant do
  menu parent: 'Roasters', priority: 4, label: 'Coffee Variants'
  
  permit_params :coffee_id, :grind_type, :bag_size, :price, :stock
  
  index do
    selectable_column
    id_column
    
    column :coffee do |variant|
      link_to variant.coffee.name, admin_coffee_path(variant.coffee)
    end
    
    column :roaster do |variant|
      link_to variant.coffee.roaster.name, admin_roaster_path(variant.coffee.roaster)
    end
    
    column :grind_type
    column :bag_size
    
    column :price do |variant|
      number_to_currency(variant.price, unit: "$")
    end
    
    column :stock do |variant|
      status_tag variant.stock, class: variant.stock > 10 ? 'yes' : (variant.stock > 0 ? 'warning' : 'no')
    end
    
    column :available do |variant|
      status_tag variant.available? ? 'In Stock' : 'Out of Stock', class: variant.available? ? 'yes' : 'no'
    end
    
    column :created_at
    actions
  end
  
  filter :coffee, as: :select, collection: -> { Coffee.includes(:roaster).order('roasters.name, coffees.name').map { |c| ["#{c.roaster.name} - #{c.name}", c.id] } }
  filter :grind_type
  filter :bag_size
  filter :price
  filter :stock
  filter :created_at
  
  show do
    attributes_table do
      row :id
      
      row :coffee do |variant|
        link_to variant.coffee.name, admin_coffee_path(variant.coffee)
      end
      
      row :roaster do |variant|
        link_to variant.coffee.roaster.name, admin_roaster_path(variant.coffee.roaster)
      end
      
      row :grind_type
      row :bag_size
      
      row :full_name do |variant|
        variant.full_name
      end
      
      row :price do |variant|
        number_to_currency(variant.price, unit: "$", precision: 2)
      end
      
      row :stock do |variant|
        status_tag variant.stock, class: variant.stock > 10 ? 'yes' : (variant.stock > 0 ? 'warning' : 'no')
      end
      
      row :available do |variant|
        status_tag variant.available? ? 'Available' : 'Out of Stock', class: variant.available? ? 'yes' : 'no'
      end
      
      row :created_at
      row :updated_at
    end
    
    panel "Coffee Information" do
      attributes_table_for coffee_variant.coffee do
        row :name
        row :description
        row :origin_country
        row :roast_level
        row :is_active do |coffee|
          status_tag coffee.is_active ? 'Active' : 'Inactive'
        end
      end
    end
  end
  
  form do |f|
    f.inputs "Variant Details" do
      f.input :coffee, as: :select, 
              collection: Coffee.includes(:roaster)
                                .order('roasters.name, coffees.name')
                                .group_by { |c| c.roaster.name }
                                .map { |roaster_name, coffees| 
                                  [roaster_name, coffees.map { |c| [c.name, c.id] }] 
                                },
              label: "Coffee",
              hint: "Select the coffee for this variant"
                                
      f.input :grind_type, as: :select,
              collection: [
                'Whole Bean',
                'Espresso',
                'Filter/Pour Over',
                'French Press',
                'Cold Brew',
                'Turkish',
                'Moka Pot'
              ],
              include_blank: 'Select grind type',
              label: "Grind Type",
              hint: "Type of grind or 'Whole Bean' if not ground"
      
      f.input :bag_size, as: :select,
              collection: [
                '100g',
                '250g',
                '340g',
                '500g',
                '1kg',
                '2kg',
                '5kg'
              ],
              include_blank: 'Select bag size',
              label: "Bag Size",
              hint: "Weight of the coffee bag"
    end
    
    f.inputs "Pricing & Inventory" do
      f.input :price, label: "Price ($)", 
              hint: "Price in dollars (e.g., 14.99)",
              input_html: { step: 0.01, min: 0 }
      
      f.input :stock, label: "Stock Quantity",
              hint: "Number of units available in inventory",
              input_html: { min: 0 }
    end
    
    f.actions
  end
  
  action_item :add_stock, only: :show do
    link_to 'Add Stock', add_stock_admin_coffee_variant_path(coffee_variant), method: :get
  end
  
  action_item :reduce_stock, only: :show do
    link_to 'Reduce Stock', reduce_stock_admin_coffee_variant_path(coffee_variant), method: :get
  end
  
  member_action :add_stock, method: :get do
    render 'admin/coffee_variants/adjust_stock', locals: { variant: resource, action: 'add' }
  end
  
  member_action :reduce_stock, method: :get do
    render 'admin/coffee_variants/adjust_stock', locals: { variant: resource, action: 'reduce' }
  end
  
  member_action :update_stock, method: :post do
    quantity = params[:quantity].to_i
    action_type = params[:action_type]
    
    if action_type == 'add'
      if resource.add_stock(quantity)
        redirect_to admin_coffee_variant_path(resource), notice: "Successfully added #{quantity} units to stock."
      else
        redirect_to admin_coffee_variant_path(resource), alert: "Failed to add stock."
      end
    elsif action_type == 'reduce'
      if resource.reduce_stock(quantity)
        redirect_to admin_coffee_variant_path(resource), notice: "Successfully reduced #{quantity} units from stock."
      else
        redirect_to admin_coffee_variant_path(resource), alert: "Failed to reduce stock: #{resource.errors.full_messages.join(', ')}"
      end
    end
  end
end

