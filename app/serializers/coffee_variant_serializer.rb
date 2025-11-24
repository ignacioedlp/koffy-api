class CoffeeVariantSerializer
  include JSONAPI::Serializer

  # ========================================
  # PUBLIC INFORMATION (all can see)
  # ========================================
  # Information that customers need to make purchase decisions
  attributes :id, :grind_type, :bag_size, :price, :created_at, :updated_at

  # ========================================
  # STOCK INFORMATION
  # ========================================
  # Show availability status but not exact stock numbers to the public
  attribute :available do |variant|
    variant.available?
  end

  # ========================================
  # PRIVILEGED INFORMATION (only roaster members)
  # ========================================
  # Exact stock numbers are only visible to roaster members
  attribute :stock, if: Proc.new { |variant, params|
    params && params[:current_user] && params[:current_user].member_of?(variant.coffee.roaster)
  } do |variant|
    variant.stock
  end

  # Full name for display purposes
  attribute :full_name do |variant|
    variant.full_name
  end
end
