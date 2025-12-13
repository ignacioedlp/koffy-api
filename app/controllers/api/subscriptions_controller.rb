class Api::SubscriptionsController < Api::ApiController
  before_action :authenticate_user!
  before_action :set_subscription, only: [ :update, :destroy ]

  def index
    @subscriptions = current_user.subscriptions.includes(subscription_items: { coffee_variant: { coffee: :roaster } })
    render json: @subscriptions, include: {
      subscription_items: {
        include: {
          coffee_variant: {
            include: {
              coffee: {
                include: :roaster
              }
            }
          }
        }
      }
    }
  end

  def create
    @subscription = current_user.subscriptions.build(subscription_params)
    @subscription.active = true # Default to active

    if @subscription.save
      render json: @subscription, status: :created
    else
      render json: { errors: @subscription.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @subscription.update(subscription_params)
      render json: @subscription
    else
      render json: { errors: @subscription.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @subscription.destroy
    head :no_content
  end

  private

  def set_subscription
    @subscription = current_user.subscriptions.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Subscription not found" }, status: :not_found
  end

  def subscription_params
    params.require(:subscription).permit(
      :day_of_month,
      :active,
      :name,
      :pickup_or_delivery,
      subscription_items_attributes: [ :id, :coffee_variant_id, :quantity, :_destroy ]
    )
  end
end
