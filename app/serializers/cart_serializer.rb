class CartSerializer
  include JSONAPI::Serializer
  attributes :id, :total_price, :total_items

  attribute :items_by_roaster do |cart|
    cart.cart_items.includes(coffee_variant: { coffee: :roaster }).group_by do |item|
      item.coffee_variant&.coffee&.roaster
    end.reject { |roaster, _| roaster.nil? }.map do |roaster, items|
      {
        roaster: {
          id: roaster.id,
          name: roaster.name,
          slug: roaster.slug
        },
        items: items.map do |item|
          {
            id: item.id,
            quantity: item.quantity,
            total_price: item.total_price,
            images: item.coffee_variant.coffee.images.attached? ? item.coffee_variant.coffee.images.map { |image| "#{ENV['R2_PUBLIC_URL']}/#{image.key}" } : [],
            coffee_variant: {
              id: item.coffee_variant.id,
              grind_type: item.coffee_variant.grind_type,
              bag_size: item.coffee_variant.bag_size,
              price: item.coffee_variant.price,
              stock: item.coffee_variant.stock,
              coffee: {
                id: item.coffee_variant.coffee.id,
                name: item.coffee_variant.coffee.name,
                slug: item.coffee_variant.coffee.slug,
                description: item.coffee_variant.coffee.description,
                roast_level: item.coffee_variant.coffee.roast_level
              }
            }
          }
        end,
        subtotal: items.sum(&:total_price)
      }
    end
  end
end
