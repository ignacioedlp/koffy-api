class Api::Roaster::SubscriptionsController < Api::Roaster::RoasterController
  def index
    @subscriptions = Subscription
      .joins(subscription_items: { coffee_variant: :coffee })
      .where(coffees: { roaster_id: @roaster.id })
      .distinct
      .includes(subscription_items: { coffee_variant: { coffee: :roaster } })
      .order(day_of_month: :asc)

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
end
