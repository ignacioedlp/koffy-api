ActiveAdmin.register Coffee do
  menu parent: 'Roasters', priority: 2
  
  permit_params :roaster_id, :name, :description, :origin_country, :varietal, 
                :process_method, :roast_level, :flavor_notes, :image_url, 
                :is_active, :featured, category_ids: []
  
  index do
    selectable_column
    id_column
    
    column :roaster do |coffee|
      link_to coffee.roaster.name, admin_roaster_path(coffee.roaster)
    end
    
    column :name
    column :origin_country
    column :roast_level
    
    column :is_active do |coffee|
      status_tag coffee.is_active ? 'Active' : 'Inactive', class: coffee.is_active ? 'yes' : 'no'
    end
    
    column :featured do |coffee|
      status_tag coffee.featured ? 'Featured' : 'Regular', class: coffee.featured ? 'yes' : 'no'
    end
    
    column :total_stock do |coffee|
      coffee.total_stock
    end
    
    column :categories do |coffee|
      coffee.categories.pluck(:name).join(', ')
    end
    
    column :created_at
    actions
  end
  
  filter :roaster, as: :select, collection: -> { Roaster.order(:name) }
  filter :name
  filter :origin_country
  filter :roast_level
  filter :process_method
  filter :is_active
  filter :featured
  filter :created_at
  
  show do
    attributes_table do
      row :id
      
      row :roaster do |coffee|
        link_to coffee.roaster.name, admin_roaster_path(coffee.roaster)
      end
      
      row :name
      row :description
      row :origin_country
      row :varietal
      row :process_method
      row :roast_level
      row :flavor_notes
      
      row :image_url do |coffee|
        if coffee.image_url.present?
          link_to coffee.image_url, coffee.image_url, target: '_blank'
        else
          'No image'
        end
      end
      
      row :is_active do |coffee|
        status_tag coffee.is_active ? 'Active' : 'Inactive', class: coffee.is_active ? 'yes' : 'no'
      end
      
      row :featured do |coffee|
        status_tag coffee.featured ? 'Featured' : 'Regular', class: coffee.featured ? 'yes' : 'no'
      end
      
      row :created_at
      row :updated_at
    end
    
    panel "Categories" do
      if coffee.categories.any?
        table_for coffee.categories do
          column :name
          column :description
          column :color do |category|
            span style: "background-color: #{category.color}; padding: 5px 10px; color: white;" do
              category.color || 'N/A'
            end
          end
          column :position
        end
      else
        para "No categories assigned yet."
      end
    end
    
      panel "Coffee Variants" do
      if coffee.coffee_variants.any?
        table_for coffee.coffee_variants do
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
          column :actions do |variant|
            links = []
            links << link_to('View', admin_coffee_variant_path(variant))
            links << link_to('Edit', edit_admin_coffee_variant_path(variant))
            links << link_to('+ Stock', add_stock_admin_coffee_variant_path(variant))
            links.join(' | ').html_safe
          end
        end
        div style: "margin-top: 10px;" do
          span do
            link_to "View All Variants", admin_coffee_variants_path(q: { coffee_id_eq: coffee.id })
          end
          span style: "margin-left: 20px;" do
            link_to "Add New Variant", new_admin_coffee_variant_path(coffee_variant: { coffee_id: coffee.id }), class: 'button'
          end
        end
      else
        para "No variants added yet. Add at least one variant with pricing and stock information."
        div style: "margin-top: 10px;" do
          link_to "Add First Variant", new_admin_coffee_variant_path(coffee_variant: { coffee_id: coffee.id }), class: 'button'
        end
      end
    end
  end
  
  form do |f|
    f.inputs "Coffee Details" do
      f.input :roaster, as: :select, collection: Roaster.order(:name)
      
      f.input :name, label: "Coffee Name"
      f.input :description, as: :text, input_html: { rows: 4 }
      
      f.input :origin_country, as: :select, 
              collection: [
                'Colombia', 'Brazil', 'Ethiopia', 'Kenya', 'Costa Rica',
                'Guatemala', 'Honduras', 'Peru', 'Mexico', 'Indonesia',
                'Vietnam', 'Rwanda', 'Burundi', 'El Salvador', 'Nicaragua',
                'Panama', 'Jamaica', 'Yemen', 'India', 'Papua New Guinea'
              ].sort,
              include_blank: 'Select a country',
              label: "Origin Country",
              hint: "Select the country where this coffee was grown"
      
      f.input :varietal, as: :select,
              collection: ['Arabica', 'Robusta', 'Liberica', 'Excelsa', 'Blend'],
              include_blank: 'Select a varietal',
              label: "Varietal",
              hint: "Coffee plant variety"
      
      f.input :process_method, as: :select,
              collection: ['Washed (Wet)', 'Natural (Dry)', 'Honey', 'Semi-washed', 'Wet-hulled'],
              include_blank: 'Select a process method',
              label: "Process Method",
              hint: "How the coffee cherry was processed"
      
      f.input :roast_level, as: :select,
              collection: ['Light', 'Medium-Light', 'Medium', 'Medium-Dark', 'Dark'],
              include_blank: 'Select roast level',
              label: "Roast Level",
              hint: "Degree of roasting applied to the beans"
      f.input :flavor_notes, as: :text, input_html: { rows: 3 }, 
              hint: "Comma-separated flavor notes (e.g., chocolate, caramel, fruity)"
      f.input :image_url, label: "Image URL"
    end
    
    f.inputs "Categories" do
      f.input :categories, as: :check_boxes, 
              collection: f.object.roaster_id ? Category.where(roaster_id: f.object.roaster_id) : []
    end
    
    f.inputs "Status" do
      f.input :is_active, label: "Active"
      f.input :featured, label: "Featured (highlight this coffee)"
    end
    
    f.actions
  end
end

