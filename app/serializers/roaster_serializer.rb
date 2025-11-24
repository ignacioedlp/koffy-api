class RoasterSerializer
  include JSONAPI::Serializer
  
  # ========================================
  # PUBLIC INFORMATION (all can see)
  # ========================================
  # Basic catalog public information
  # Coffee lovers can see this information to decide where to buy
  attributes :id, :name, :location, :description, :active, :created_at, :updated_at
  
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

