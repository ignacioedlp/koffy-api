class FavoriteSerializer
  include JSONAPI::Serializer

  attributes :id, :favoritable_type, :favoritable_id, :created_at

  attribute :user_id do |favorite|
    favorite.user_id
  end

  attribute :user_email do |favorite|
    favorite.user&.email
  end

  attribute :favoritable do |favorite|
    if favorite.favoritable.present?
      case favorite.favoritable_type
      when "Coffee"
        {
          id: favorite.favoritable.id,
          name: favorite.favoritable.name,
          slug: favorite.favoritable.slug,
          description: favorite.favoritable.description,
          roaster_name: favorite.favoritable.roaster&.name,
          images: favorite.favoritable.images.attached? ? favorite.favoritable.images.map { |image| "#{ENV['R2_PUBLIC_URL']}/#{image.key}" } : []
        }
      when "Roaster"
        {
          id: favorite.favoritable.id,
          name: favorite.favoritable.name,
          slug: favorite.favoritable.slug,
          description: favorite.favoritable.description,
          location: favorite.favoritable.location,
          logo_url: favorite.favoritable.logo.attached? ? "#{ENV['R2_PUBLIC_URL']}/#{favorite.favoritable.logo.key}" : nil,
          image_url: favorite.favoritable.image.attached? ? "#{ENV['R2_PUBLIC_URL']}/#{favorite.favoritable.image.key}" : nil
        }
      when "CoffeeVariant"
        {
          id: favorite.favoritable.id,
          grind_type: favorite.favoritable.grind_type,
          bag_size: favorite.favoritable.bag_size,
          price: favorite.favoritable.price,
          coffee_name: favorite.favoritable.coffee&.name
        }
      else
        nil
      end
    end
  end
end
