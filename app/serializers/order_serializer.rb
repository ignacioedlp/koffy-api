class OrderSerializer
  include JSONAPI::Serializer
  
  # ========================================
  # PUBLIC INFORMATION (all can see)
  # ========================================
  # Basic order information visible to customers and roaster members
  attributes :id, :status, :total_amount, :pickup_or_delivery, 
             :delivery_address, :pickup_time, :notes, 
             :qr_code_data, :created_at, :updated_at
  
  # Customer information (visible to roaster members)
  attribute :customer_email do |order|
    order.user.email
  end
  
  attribute :customer_name do |order|
    order.user.name
  end
  
  attribute :customer_id do |order|
    order.user_id
  end
  
  # Roaster information
  attribute :roaster_id do |order|
    order.roaster_id
  end
  
  attribute :roaster_name do |order|
    order.roaster.name
  end
  
  # Order items (always included)
  attribute :order_items do |order|
    order.order_items.map do |item|
      {
        id: item.id,
        coffee_variant_id: item.coffee_variant_id,
        coffee_name: item.coffee_variant.coffee.name,
        variant_name: item.coffee_variant.name,
        quantity: item.quantity,
        unit_price: item.unit_price,
        subtotal: item.subtotal
      }
    end
  end
  
  # Total quantity of items
  attribute :total_quantity do |order|
    order.total_quantity
  end
  
  # ========================================
  # PRIVILEGED INFORMATION (only roaster members)
  # ========================================
  
  # Additional customer information (only for roaster members)
  attribute :customer_phone, if: Proc.new { |order, params|
    params && params[:current_user] && params[:current_user].member_of?(order.roaster)
  } do |order|
    order.user.phone
  end
  
  # Internal notes or special instructions (only for roaster members)
  attribute :internal_notes, if: Proc.new { |order, params|
    params && params[:current_user] && params[:current_user].member_of?(order.roaster)
  } do |order|
    # This could be a field added to the Order model in the future
    # For now, we'll return nil or empty
    nil
  end
  
  # Indicates if the current user is the customer
  attribute :is_my_order do |order, params|
    params && params[:current_user] && order.user_id == params[:current_user].id
  end
  
  # Indicates if the current user is a member of the roaster
  attribute :is_roaster_member do |order, params|
    params && params[:current_user] && params[:current_user].member_of?(order.roaster)
  end
end

