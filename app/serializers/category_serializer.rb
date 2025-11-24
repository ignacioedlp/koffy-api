class CategorySerializer
  include JSONAPI::Serializer

  # ========================================
  # PUBLIC INFORMATION (all can see)
  # ========================================
  # Basic category information for browsing and filtering
  attributes :id, :name, :description, :color, :icon, :position

  # Roaster information
  attribute :roaster_id do |category|
    category.roaster_id
  end

  attribute :roaster_name do |category|
    category.roaster.name
  end

  # Count of active coffees in this category (public)
  attribute :active_coffees_count do |category|
    category.active_coffees_count
  end

  # ========================================
  # PRIVILEGED INFORMATION (only roaster members)
  # ========================================

  # Show inactive status only to members
  attribute :is_active, if: Proc.new { |category, params|
    params && params[:current_user] && params[:current_user].member_of?(category.roaster)
  } do |category|
    category.is_active
  end

  # Total coffees count including inactive ones (only for members)
  attribute :total_coffees_count, if: Proc.new { |category, params|
    params && params[:current_user] && params[:current_user].member_of?(category.roaster)
  } do |category|
    category.coffees_count
  end

  # ========================================
  # NESTED COFFEES (conditional inclusion)
  # ========================================
  # Include coffees when requested
  attribute :coffees, if: Proc.new { |category, params|
    params && params[:include_coffees] == true
  } do |category, params|
    # Only show active coffees to non-members
    coffees = if params[:current_user] && params[:current_user].member_of?(category.roaster)
      category.coffees
    else
      category.coffees.active
    end

    CoffeeSerializer.new(
      coffees,
      { params: params }
    ).serializable_hash[:data].map { |c| c[:attributes] }
  end
end
