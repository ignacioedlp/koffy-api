class ReviewSerializer
  include JSONAPI::Serializer

  # ========================================
  # PUBLIC INFORMATION (all can see)
  # ========================================
  # Reviews are public information - anyone can see them
  attributes :id, :rating, :comment, :created_at, :updated_at

  # User information (who wrote the review)
  attribute :user_id do |review|
    review.user_id
  end

  attribute :user_email do |review|
    review.user.email
  end

  attribute :user_name do |review|
    review.user.name
  end

  # Roaster information (who was reviewed)
  attribute :roaster_id do |review|
    review.roaster_id
  end

  attribute :roaster_name do |review|
    review.roaster.name
  end

  # Formatted rating for display
  attribute :rating_display do |review|
    "#{review.rating} / 5.0"
  end
end
