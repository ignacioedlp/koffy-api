class RoasterSerializer
  include JSONAPI::Serializer

  # ========================================
  # PUBLIC INFORMATION (all can see)
  # ========================================
  # Basic catalog public information
  # Coffee lovers can see this information to decide where to buy
  attributes :id, :name, :slug, :location, :description, :active, :created_at, :updated_at, :tags

  attribute :coffees_count do |roaster|
    roaster.coffees.active.count
  end

  # Logo URL
  attribute :logo_url do |roaster|
    if roaster.logo.attached?
      "#{ENV['R2_PUBLIC_URL']}/#{roaster.logo.key}"
    else
      nil
    end
  end

  attribute :image_url do |roaster|
    if roaster.image.attached?
      "#{ENV['R2_PUBLIC_URL']}/#{roaster.image.key}"
    else
      nil
    end
  end

  # Business hours
  attribute :business_hours do |roaster|
    roaster.business_hours.ordered_by_day.map do |bh|
      {
        day_of_week: bh.day_of_week,
        opens_at: bh.opens_at&.strftime("%H:%M"),
        closes_at: bh.closes_at&.strftime("%H:%M"),
        is_closed: bh.is_closed,
        number_day_of_week: BusinessHour.day_of_weeks[bh.day_of_week]
      }
    end
  end

  attribute :feature_coffees, if: Proc.new { |roaster, params|
    params &&
    params[:include_coffees_feature] == true
  } do |roaster, params|
    roaster.coffees.featured_active.map do |coffee|
      coffee_data = CoffeeSerializer.new(coffee, {
        params: { current_user: params[:current_user], include_variants: true }
      }).serializable_hash[:data][:attributes]
    end
  end

  attribute :is_favorite do |roaster, params|
    if params && params[:current_user]
      roaster.favorited_by?(params[:current_user]).exists?
    else
      false
    end
  end

  attribute :favorite_id do |roaster, params|
    if params && params[:current_user]
      roaster.favorited_by?(params[:current_user]).first&.id
    else
      false
    end
  end

  # ========================================
  # PRIVILEGED INFORMATION (only members)
  # ========================================

  # Atributo: user_role
  # ONLY included if user is a member of the roaster
  # Coffee lovers NO verán este campo
  attribute :user_role, if: Proc.new { |roaster, params|
    params && params[:current_user] && params[:current_user].member_of?(roaster)
  } do |roaster, params|
    # Returns the user's role in this roaster (owner, manager, barista, member)
    params[:current_user].role_in(roaster)
  end

  # Atributo: is_member
  # Useful for the frontend: indicates if the user is a member or just a visitor
  attribute :is_member do |roaster, params|
    params && params[:current_user] ? params[:current_user].member_of?(roaster) : false
  end

  # Internal statistics attributes
  # ONLY included if:
  # 1. Explicitly requested (include_members: true)
  # 2. And the user is a member of the roaster
  attribute :members_count, if: Proc.new { |roaster, params|
    params &&
    params[:include_members] == true &&
    params[:current_user] &&
    params[:current_user].member_of?(roaster)
  } do |roaster|
    # Count only active memberships
    roaster.roaster_memberships.active.count
  end

  attribute :owners_count, if: Proc.new { |roaster, params|
    params &&
    params[:include_members] == true &&
    params[:current_user] &&
    params[:current_user].member_of?(roaster)
  } do |roaster|
    # Count how many owners the roaster has
    roaster.roaster_memberships.active.owners.count
  end

  attribute :managers_count, if: Proc.new { |roaster, params|
    params &&
    params[:include_members] == true &&
    params[:current_user] &&
    params[:current_user].member_of?(roaster)
  } do |roaster|
    # Count how many managers the roaster has
    roaster.roaster_memberships.active.managers.count
  end

  attribute :baristas_count, if: Proc.new { |roaster, params|
    params &&
    params[:include_members] == true &&
    params[:current_user] &&
    params[:current_user].member_of?(roaster)
  } do |roaster|
    # Count how many baristas the roaster has
    roaster.roaster_memberships.active.baristas.count
  end
end
