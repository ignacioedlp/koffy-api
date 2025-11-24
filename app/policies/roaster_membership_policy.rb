# frozen_string_literal: true

# Policy to authorize RoasterMembership actions
class RoasterMembershipPolicy < ApplicationPolicy
  # Scope to filter memberships based on user permissions
  class Scope < ApplicationPolicy::Scope
    def resolve
      # Users can see memberships of roasters they belong to
      scope.joins(:roaster)
           .where(roasters: { id: user.roasters.pluck(:id) })
    end
  end
  
  # Users can view memberships if they are part of the roaster
  def index?
    user.member_of?(record.roaster)
  end
  
  # Users can view a membership if they are part of the roaster
  def show?
    user.member_of?(record.roaster)
  end
  
  # Only owners and managers can create memberships (invite users)
  def create?
    user.can_manage?(record.roaster)
  end
  
  # Only owners and managers can update memberships (change roles)
  # But owners cannot demote themselves
  def update?
    return false unless user.can_manage?(record.roaster)
    
    # Owners cannot change their own role
    return false if record.user_id == user.id && record.owner?
    
    # Only owners can promote someone to owner
    return user.owner_of?(record.roaster) if record.role_changed? && record.owner?
    
    true
  end
  
  # Only owners and managers can remove members
  # But cannot remove themselves if they are the only owner
  def destroy?
    return false unless user.can_manage?(record.roaster)
    
    # Cannot remove the last owner
    if record.owner?
      owners_count = record.roaster.roaster_memberships.owners.count
      return false if owners_count <= 1
    end
    
    true
  end
  
  # Only owners and managers can activate/deactivate memberships
  def toggle_active?
    user.can_manage?(record.roaster)
  end
  
  # Users can leave a roaster (deactivate their own membership)
  # But owners must transfer ownership first
  def leave?
    return false if record.owner? && record.roaster.roaster_memberships.owners.count <= 1
    
    record.user_id == user.id
  end
end
