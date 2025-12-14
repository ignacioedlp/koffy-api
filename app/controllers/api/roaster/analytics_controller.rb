class Api::Roaster::AnalyticsController < Api::Roaster::RoasterController
  def show
    start_date = params[:start_date] ? Date.parse(params[:start_date]) : 30.days.ago.to_date
    end_date = params[:end_date] ? Date.parse(params[:end_date]) : Date.today

    # Cafés del roaster
    coffee_ids = @roaster.coffees.pluck(:id)
    variant_ids = CoffeeVariant.where(coffee_id: coffee_ids).pluck(:id)

    # Órdenes de variantes de este roaster
    orders = Order.joins(:order_items).where(order_items: { coffee_variant_id: variant_ids }, created_at: start_date.beginning_of_day..end_date.end_of_day).distinct
    total_earnings = orders.map(&:calculate_total).sum
    total_orders = orders.count

    # Usuarios alcanzados (compraron o se suscribieron a alguna variante)
    user_ids_from_orders = orders.pluck(:user_id)
    user_ids_from_subs = SubscriptionItem.joins(:subscription).where(coffee_variant_id: variant_ids).pluck('subscriptions.user_id')
    reached_users = (user_ids_from_orders + user_ids_from_subs).uniq.count

    # Cantidad de suscripciones (subscriptions that include variants from this roaster)
    total_subscriptions = Subscription.joins(:subscription_items)
                      .where(subscription_items: { coffee_variant_id: variant_ids }, created_at: start_date.beginning_of_day..end_date.end_of_day)
                      .distinct
                      .count

    # Órdenes por día (incluye días sin órdenes con 0)
    orders_by_day_raw = orders.group("DATE(orders.created_at)").count
    orders_by_day = {}
    (start_date..end_date).each do |date|
      orders_by_day[date.to_s] = orders_by_day_raw[date] || orders_by_day_raw[date.to_s] || 0
    end

    render json: {
      total_earnings: total_earnings,
      reached_users: reached_users,
      total_subscriptions: total_subscriptions,
      total_orders: total_orders,
      orders_by_day: orders_by_day
    }
  end
end
