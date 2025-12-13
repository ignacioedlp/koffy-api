class Api::CartItemsController < Api::ApiController
  before_action :authenticate_user!
  before_action :set_cart

  def create
    @cart_item = @cart.cart_items.find_or_initialize_by(coffee_variant_id: cart_item_params[:coffee_variant_id])

    if @cart_item.persisted?
      @cart_item.quantity += cart_item_params[:quantity].to_i
    else
      @cart_item.quantity = cart_item_params[:quantity].to_i
    end

    if @cart_item.save
      render json: CartItemSerializer.new(@cart_item).serializable_hash, status: :created
    else
      render json: @cart_item.errors, status: :unprocessable_entity
    end
  end

  def update
    @cart_item = @cart.cart_items.find(params[:id])
    if @cart_item.update(cart_item_params)
      render json: CartItemSerializer.new(@cart_item).serializable_hash
    else
      render json: @cart_item.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @cart_item = @cart.cart_items.find(params[:id])
    @cart_item.destroy
    head :no_content
  end

  private

  def set_cart
    @cart = current_user.cart || current_user.create_cart
  end

  def cart_item_params
    params.require(:cart_item).permit(:coffee_variant_id, :quantity)
  end
end
