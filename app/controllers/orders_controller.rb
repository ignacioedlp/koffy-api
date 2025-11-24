class OrdersController < ApplicationController
  # Authenticate user for all actions (orders require authentication)
  before_action :authenticate_user!
  before_action :set_order, only: [ :show, :update ]

  # GET /orders
  # List orders for the current user
  # - Coffee lovers: See only their own orders
  # - Roaster members: See their own orders + orders for roasters they belong to
  #
  # Query parameters:
  # - roaster_id: Filter by roaster (for roaster members)
  # - status: Filter by order status
  # - page: Page number (default: 1)
  # - per_page: Items per page (default: 20, max: 100)
  def index
    authorize Order

    # Use policy scope to filter orders based on user permissions
    @orders = policy_scope(Order)

    # Apply filters
    @orders = @orders.where(roaster_id: params[:roaster_id]) if params[:roaster_id].present?
    @orders = @orders.by_status(params[:status]) if params[:status].present?

    # Default ordering: most recent first
    @orders = @orders.recent

    # Pagination
    # Default: 20 items per page, maximum: 100 items per page
    per_page = if params[:per_page].present?
                  requested = params[:per_page].to_i
                  requested > 0 ? [ requested, 100 ].min : 20
    else
                  20
    end
    @orders = @orders.page(params[:page] || 1).per(per_page)

    # Serialize the paginated collection
    serialized_data = OrderSerializer.new(@orders, {
      params: { current_user: current_user }
    }).serializable_hash

    # Add pagination metadata
    render json: {
      data: serialized_data[:data],
      meta: {
        pagination: {
          current_page: @orders.current_page,
          per_page: @orders.limit_value,
          total_pages: @orders.total_pages,
          total_count: @orders.total_count,
          next_page: @orders.next_page,
          prev_page: @orders.prev_page,
          first_page: @orders.first_page?,
          last_page: @orders.last_page?
        }
      }
    }, status: :ok
  end

  # GET /orders/:id
  # Show details of a specific order
  # - Coffee lovers: Can see their own orders
  # - Roaster members: Can see orders for roasters they belong to
  def show
    authorize @order

    render json: OrderSerializer.new(@order, {
      params: { current_user: current_user }
    }).serializable_hash, status: :ok
  end

  # POST /orders
  # Create a new order (ONLY COFFEE LOVERS)
  # Expects JSON body with:
  # {
  #   "order": {
  #     "roaster_id": 1,
  #     "pickup_or_delivery": "pickup",
  #     "delivery_address": "123 Main St",
  #     "pickup_time": "2024-01-15T10:00:00Z",
  #     "notes": "Please grind medium",
  #     "order_items_attributes": [
  #       {
  #         "coffee_variant_id": 1,
  #         "quantity": 2,
  #         "unit_price": 15.99
  #       }
  #     ]
  #   }
  # }
  def create
    @order = current_user.orders.build(order_params)
    authorize @order

    # Set default status if not provided
    @order.status ||= "pending"

    if @order.save
      # Calculate and update total amount
      @order.update_total!

      render json: {
        message: "Order created successfully",
        order: OrderSerializer.new(@order, {
          params: { current_user: current_user }
        }).serializable_hash[:data][:attributes]
      }, status: :created
    else
      render json: { errors: @order.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /orders/:id
  # Update an order (ONLY ROASTER MEMBERS with editing privileges)
  # Only members of the roaster assigned to the order can update it
  # Expects JSON body with:
  # {
  #   "order": {
  #     "status": "confirmed",
  #     "notes": "Updated notes"
  #   }
  # }
  def update
    authorize @order

    if @order.update(order_params)
      # Recalculate total if order items changed
      @order.update_total! if order_params[:order_items_attributes].present?

      render json: {
        message: "Order updated successfully",
        order: OrderSerializer.new(@order, {
          params: { current_user: current_user }
        }).serializable_hash[:data][:attributes]
      }, status: :ok
    else
      render json: { errors: @order.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # POST /orders/scan_qr
  # Confirm an order by scanning its QR code
  # Only roaster members with editing privileges can scan and confirm orders
  # Expects JSON body with:
  # {
  #   "qr_code": "ORDER-1234567890-ABCDEF1234567890",
  #   "new_status": "completed"  # Optional, defaults to "completed"
  # }
  def scan_qr
    qr_code = params[:qr_code]

    if qr_code.blank?
      return render json: { error: "QR code is required" }, status: :bad_request
    end

    # Find order by QR code
    @order = Order.by_qr_code(qr_code).first

    unless @order
      return render json: { error: "Order not found with the provided QR code" }, status: :not_found
    end

    # Authorize: user must be a member of the roaster with editing privileges
    authorize @order, :update?

    # Determine new status (default to "completed" if not provided)
    new_status = params[:new_status] || "completed"

    # Validate status against allowed values
    allowed_statuses = [ "pending", "confirmed", "preparing", "ready", "completed", "cancelled" ]
    unless allowed_statuses.include?(new_status)
      return render json: { error: "Invalid status: #{new_status}. Allowed values: #{allowed_statuses.join(', ')}" }, status: :bad_request
    end

    # Update order status
    if @order.update(status: new_status)
      render json: {
        message: "Order confirmed successfully via QR code",
        order: OrderSerializer.new(@order, {
          params: { current_user: current_user }
        }).serializable_hash[:data][:attributes]
      }, status: :ok
    else
      render json: { errors: @order.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_order
    @order = Order.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Order not found" }, status: :not_found
  end

  def order_params
    params.require(:order).permit(
      :roaster_id,
      :status,
      :pickup_or_delivery,
      :delivery_address,
      :pickup_time,
      :notes,
      order_items_attributes: [
        :id,
        :coffee_variant_id,
        :quantity,
        :unit_price,
        :_destroy
      ]
    )
  end
end
