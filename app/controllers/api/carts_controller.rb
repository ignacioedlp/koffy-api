class Api::CartsController < Api::ApiController
  before_action :authenticate_user!

  def show
    cart = current_user.cart || current_user.create_cart
    render json: CartSerializer.new(cart).serializable_hash
  end
end
