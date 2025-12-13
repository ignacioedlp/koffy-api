class CoffeeSerializer
  include JSONAPI::Serializer

  # ========================================
  # PUBLIC INFORMATION (all can see)
  # ========================================
  # Information that customers need to browse and choose coffees
  attributes :id, :name, :slug, :description, :origin_country, :varietal,
             :process_method, :roast_level, :flavor_notes,
             :featured, :created_at, :updated_at

  # Roaster information (public)
  attribute :roaster_name do |coffee|
    coffee.roaster.name
  end

  attribute :roaster_id do |coffee|
    coffee.roaster_id
  end

  # Price range for public (min and max from variants)
  attribute :min_price do |coffee|
    coffee.min_price
  end

  attribute :max_price do |coffee|
    coffee.max_price
  end

  # General availability status (not exact stock numbers)
  attribute :in_stock do |coffee|
    coffee.in_stock?
  end

  # Category names for easy filtering
  attribute :categories do |coffee|
    coffee.categories.active.map { |cat| { id: cat.id, name: cat.name, color: cat.color } }
  end

  # Images URLs (public)
  attribute :images do |coffee|
    if coffee.images.attached?
      coffee.images.map { |image| "#{ENV['R2_PUBLIC_URL']}/#{image.key}" }
    else
      []
    end
  end

  attribute :is_favorite do |coffee, params|
    if params && params[:current_user]
      coffee.favorited_by?(params[:current_user])
    else
      false
    end
  end

  attribute :is_favorite do |coffee, params|
    if params && params[:current_user]
      coffee.favorited_by?(params[:current_user]).exists?
    else
      false
    end
  end

  attribute :favorite_id do |coffee, params|
    if params && params[:current_user]
      coffee.favorited_by?(params[:current_user]).first&.id
    else
      false
    end
  end


  # ========================================
  # PRIVILEGED INFORMATION (only roaster members)
  # ========================================

  # Exact stock information (only for members)
  attribute :total_stock, if: Proc.new { |coffee, params|
    params && params[:current_user] && params[:current_user].member_of?(coffee.roaster)
  } do |coffee|
    coffee.total_stock
  end

  # Active status (only members can see if coffee is inactive)
  attribute :is_active, if: Proc.new { |coffee, params|
    params && params[:current_user] && params[:current_user].member_of?(coffee.roaster)
  } do |coffee|
    coffee.is_active
  end

  # Internal notes or cost information could be added here
  # For example:
  # attribute :internal_notes, if: Proc.new { |coffee, params|
  #   params && params[:current_user] && params[:current_user].member_of?(coffee.roaster)
  # } do |coffee|
  #   coffee.internal_notes
  # end

  # ========================================
  # NESTED VARIANTS (conditional inclusion)
  # ========================================
  # Include variants when requested
  attribute :variants, if: Proc.new { |coffee, params|
    params && params[:include_variants] == true
  } do |coffee, params|
    CoffeeVariantSerializer.new(
      coffee.coffee_variants,
      { params: params }
    ).serializable_hash[:data].map { |v| v[:attributes] }
  end
end
