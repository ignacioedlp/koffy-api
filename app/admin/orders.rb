ActiveAdmin.register Order do
  # Permit parameters for create/update
  permit_params :user_id, :roaster_id, :status, :total_amount,
                :pickup_or_delivery, :qr_code_data,
                order_items_attributes: [ :id, :coffee_variant_id, :quantity, :unit_price, :_destroy ]

  # Scopes for filtering orders by status
  scope :all, default: true
  scope :pending
  scope :confirmed
  scope :preparing
  scope :ready
  scope :completed
  scope :cancelled

  # Member action to cancel an order
  member_action :cancel_order, method: :put do
    if resource.can_cancel?
      resource.cancel!
      redirect_to admin_order_path(resource), notice: "Order cancelled successfully"
    else
      redirect_to admin_order_path(resource), alert: "Cannot cancel order with status #{resource.status}"
    end
  end

  # Member action to update order status
  member_action :update_status, method: :put do
    new_status = params[:status]
    if [ "pending", "confirmed", "preparing", "ready", "completed", "cancelled" ].include?(new_status)
      resource.update(status: new_status)
      redirect_to admin_order_path(resource), notice: "Order status updated to #{new_status}"
    else
      redirect_to admin_order_path(resource), alert: "Invalid status"
    end
  end

  # Member action to recalculate total
  member_action :recalculate_total, method: :put do
    resource.update_total!
    redirect_to admin_order_path(resource), notice: "Total amount recalculated"
  end

  # Index page configuration
  index do
    selectable_column
    id_column

    column :user do |order|
      link_to order.user.email, admin_user_path(order.user)
    end

    column :roaster do |order|
      link_to order.roaster.name, admin_roaster_path(order.roaster)
    end

    column :status do |order|
      status_class = case order.status
      when "completed"
        "yes"
      when "cancelled"
        "no"
      when "pending"
        "warning"
      else
        "ok"
      end
      status_tag order.status.titleize, class: status_class
    end

    column :total_amount do |order|
      if order.total_amount
        number_to_currency(order.total_amount, unit: "$")
      else
        "Not calculated"
      end
    end

    column :pickup_or_delivery do |order|
      if order.pickup_or_delivery
        status_tag order.pickup_or_delivery.titleize,
                   class: order.pickup_or_delivery == "pickup" ? "yes" : "ok"
      else
        "N/A"
      end
    end

    column :items_count do |order|
      order.order_items.count
    end

    column :total_quantity do |order|
      order.total_quantity
    end

    column :created_at
    actions do |order|
      # Add custom actions
      unless order.completed? || order.cancelled?
        item "Cancel", cancel_order_admin_order_path(order),
             method: :put,
             class: "member_link",
             data: { confirm: "Are you sure you want to cancel this order?" }
      end
      item "Recalculate Total", recalculate_total_admin_order_path(order),
           method: :put,
           class: "member_link"
    end
  end

  # Filters for the index page
  filter :user, as: :select, collection: -> { User.order(:email) }
  filter :roaster, as: :select, collection: -> { Roaster.order(:name) }
  filter :status, as: :select, collection: [
    [ "Pending", "pending" ],
    [ "Confirmed", "confirmed" ],
    [ "Preparing", "preparing" ],
    [ "Ready", "ready" ],
    [ "Completed", "completed" ],
    [ "Cancelled", "cancelled" ]
  ]
  filter :pickup_or_delivery, as: :select, collection: [ [ "Pickup", "pickup" ], [ "Delivery", "delivery" ] ]
  filter :total_amount
  filter :created_at

  # Show page configuration
  show do
    attributes_table do
      row :id

      row :user do |order|
        link_to order.user.email, admin_user_path(order.user)
      end

      row :roaster do |order|
        link_to order.roaster.name, admin_roaster_path(order.roaster)
      end

      row :status do |order|
        status_class = case order.status
        when "completed"
          "yes"
        when "cancelled"
          "no"
        when "pending"
          "warning"
        else
          "ok"
        end
        status_tag order.status.titleize, class: status_class
      end

      row :total_amount do |order|
        if order.total_amount
          number_to_currency(order.total_amount, unit: "$")
        else
          span "Not calculated", style: "color: orange;"
        end
      end

      row :pickup_or_delivery do |order|
        if order.pickup_or_delivery
          status_tag order.pickup_or_delivery.titleize
        else
          "N/A"
        end
      end

      row :qr_code_data do |order|
        if order.qr_code_data.present?
          div style: "font-family: monospace; background: #f5f5f5; padding: 10px; border-radius: 4px;" do
            order.qr_code_data
          end
        else
          "No QR code data"
        end
      end

      row :total_quantity do |order|
        order.total_quantity
      end

      row :items_count do |order|
        order.order_items.count
      end

      row :created_at
      row :updated_at
    end

    # Panel showing order items
    panel "Order Items" do
      if order.order_items.any?
        table_for order.order_items.includes(:coffee_variant) do
          column "Coffee Variant" do |item|
            link_to item.coffee_variant.full_name, admin_coffee_variant_path(item.coffee_variant)
          end

          column "Coffee" do |item|
            link_to item.coffee_variant.coffee.name, admin_coffee_path(item.coffee_variant.coffee)
          end

          column :quantity

          column :unit_price do |item|
            number_to_currency(item.unit_price, unit: "$")
          end

          column "Subtotal" do |item|
            number_to_currency(item.subtotal, unit: "$")
          end

          column "Stock Available" do |item|
            if item.sufficient_stock?
              status_tag "#{item.coffee_variant.stock} available", class: "yes"
            else
              status_tag "Only #{item.coffee_variant.stock} available", class: "no"
            end
          end

          column :actions do |item|
            link_to "View", admin_order_item_path(item)
          end
        end

        div style: "margin-top: 15px; padding: 10px; background: #f9f9f9; border-radius: 4px;" do
          strong "Total Amount: " +
          span(number_to_currency(order.total_amount || order.calculate_total, unit: "$"),
               style: "font-size: 1.2em; color: #2e7d32;")
        end

        div style: "margin-top: 10px;" do
          link_to "View All Order Items", admin_order_items_path(q: { order_id_eq: order.id })
        end
      else
        para "No items in this order yet."
        div do
          link_to "Add First Item", new_admin_order_item_path(order_item: { order_id: order.id }), class: "button"
        end
      end
    end

    # Panel for order actions
    panel "Order Actions" do
      div style: "margin: 10px 0;" do
        unless order.completed? || order.cancelled?
          link_to "Cancel Order", cancel_order_admin_order_path(order),
                  method: :put,
                  class: "button",
                  data: { confirm: "Are you sure you want to cancel this order?" }
        end

        link_to "Recalculate Total", recalculate_total_admin_order_path(order),
                method: :put,
                class: "button",
                style: "margin-left: 10px;"

        # Quick status update buttons
        div style: "margin-top: 15px;" do
          span "Quick Status Update: ", style: "font-weight: bold;"
          [ "confirmed", "preparing", "ready", "completed" ].each do |status|
            unless order.status == status
              link_to status.titleize,
                      update_status_admin_order_path(order, status: status),
                      method: :put,
                      class: "button",
                      style: "margin-right: 5px;"
            end
          end
        end
      end
    end
  end

  # Form configuration
  form do |f|
    f.inputs "Order Details" do
      f.input :user, as: :select, collection: User.order(:email)
      f.input :roaster, as: :select, collection: Roaster.order(:name)

      f.input :status, as: :select,
              collection: [
                [ "Pending", "pending" ],
                [ "Confirmed", "confirmed" ],
                [ "Preparing", "preparing" ],
                [ "Ready", "ready" ],
                [ "Completed", "completed" ],
                [ "Cancelled", "cancelled" ]
              ],
              include_blank: false

      f.input :total_amount,
              hint: "Leave blank to calculate automatically from order items"

      f.input :pickup_or_delivery, as: :select,
              collection: [ [ "Pickup", "pickup" ], [ "Delivery", "delivery" ] ],
              include_blank: "Select option"

      f.input :qr_code_data, as: :text,
              input_html: { rows: 3 },
              hint: "QR code data for order tracking"
    end

    # Nested form for order items
    f.inputs "Order Items" do
      # Get roaster_id for filtering variants
      roaster_id = f.object.roaster_id || params[:order]&.dig(:roaster_id)

      # Build coffee variants collection
      coffee_variants_collection = if roaster_id.present?
        CoffeeVariant.joins(:coffee)
                     .where(coffees: { roaster_id: roaster_id })
                     .includes(:coffee)
                     .order("coffees.name")
                     .map { |v| [ "#{v.coffee.name} - #{v.bag_size} (#{v.grind_type}) - $#{v.price}", v.id ] }
      else
        CoffeeVariant.includes(:coffee)
                     .order("coffees.name")
                     .limit(100)
                     .map { |v| [ "#{v.coffee.name} - #{v.bag_size} (#{v.grind_type}) - $#{v.price}", v.id ] }
      end

      f.has_many :order_items, heading: "Items", allow_destroy: true, new_record: true do |item_f|
        item_f.input :coffee_variant,
                     as: :select,
                     collection: coffee_variants_collection,
                     hint: "Select the coffee variant for this item"

        item_f.input :quantity,
                     input_html: { min: 1, step: 1 },
                     hint: "Number of units"

        item_f.input :unit_price,
                     input_html: { min: 0.01, step: 0.01 },
                     hint: "Price per unit (will use variant price if blank)"

        # Show variant info if selected
        if item_f.object.coffee_variant.present?
          item_f.inputs "Variant Info", class: "variant-info" do
            li do
              content_tag :div, style: "padding: 8px; background: #f0f7ff; border-left: 3px solid #2196F3; margin: 5px 0;" do
                "Current Price: #{number_to_currency(item_f.object.coffee_variant.price, unit: '$')} | " +
                "Stock: #{item_f.object.coffee_variant.stock} | " +
                "Coffee: #{item_f.object.coffee_variant.coffee.name}"
              end
            end
          end
        end
      end
    end

    f.actions
  end

  # Controller callback to update total after save
  controller do
    def create
      super do |success, failure|
        success.html {
          resource.update_total! if resource.persisted?
          redirect_to admin_order_path(resource)
        }
      end
    end

    def update
      super do |success, failure|
        success.html {
          resource.update_total! if resource.persisted?
          redirect_to admin_order_path(resource)
        }
      end
    end
  end
end
