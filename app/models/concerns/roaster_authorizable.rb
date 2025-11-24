# app/models/concerns/roaster_authorizable.rb
# Concern to add roaster authorization methods to User model
module RoasterAuthorizable
  extend ActiveSupport::Concern
  
  included do
    # Associations
    has_many :roaster_memberships, dependent: :destroy
    has_many :roasters, through: :roaster_memberships
    
    # Only active roasters through active memberships
    has_many :active_roaster_memberships, -> { where(active: true) }, 
             class_name: 'RoasterMembership'
    has_many :active_roasters, through: :active_roaster_memberships, 
             source: :roaster
  end
  
  # Get the membership for a specific roaster
  def membership_in(roaster)
    roaster_memberships.find_by(roaster: roaster)
  end
  
  # Get the role of the user in a specific roaster
  def role_in(roaster)
    membership_in(roaster)&.role
  end
  
  # Check if user is owner of the roaster
  def owner_of?(roaster)
    role_in(roaster) == 'owner'
  end
  
  # Check if user is manager of the roaster
  def manager_of?(roaster)
    role_in(roaster) == 'manager'
  end
  
  # Check if user is barista of the roaster
  def barista_of?(roaster)
    role_in(roaster) == 'barista'
  end
  
  # Check if user is member of the roaster (any role)
  def member_of?(roaster)
    roaster_memberships.exists?(roaster: roaster, active: true)
  end
  
  # Check if user can manage the roaster (owner or manager)
  def can_manage?(roaster)
    role = role_in(roaster)
    %w[owner manager].include?(role)
  end
  
  # Check if user can edit roaster content (owner, manager, or barista)
  def can_edit?(roaster)
    role = role_in(roaster)
    %w[owner manager barista].include?(role)
  end
  
  # Check if user can view roaster content (any active member)
  def can_view?(roaster)
    member_of?(roaster)
  end
  
  # Get all roasters where user is owner
  def owned_roasters
    roasters.joins(:roaster_memberships)
            .where(roaster_memberships: { user_id: id, role: 'owner', active: true })
  end
  
  # Get all roasters where user is manager
  def managed_roasters
    roasters.joins(:roaster_memberships)
            .where(roaster_memberships: { user_id: id, role: 'manager', active: true })
  end
  
  # Add user to a roaster with a specific role
  def join_roaster(roaster, role: 'member')
    roaster_memberships.create(roaster: roaster, role: role)
  end
  
  # Remove user from a roaster (deactivate membership)
  def leave_roaster(roaster)
    membership = membership_in(roaster)
    membership&.deactivate!
  end
  
  # Change role in a roaster
  def change_role_in(roaster, new_role)
    membership = membership_in(roaster)
    membership&.update(role: new_role)
  end
end

