# frozen_string_literal: true

class CoffeePolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user
        scope.joins(:roaster)
             .where(
               "(coffees.is_active = ? AND roasters.active = ?) OR 
                roasters.id IN (?)",
               true, 
               true, 
               user.roasters.pluck(:id)
             )
      else
        # Non-authenticated users can only see active coffees from active roasters
        scope.joins(:roaster)
             .where(coffees: { is_active: true }, roasters: { active: true })
      end
    end
  end
  
  # Anyone can view the index (list of coffees)
  # This allows coffee lovers to browse available coffees
  def index?
    true
  end
  
  # Any user can view a coffee's public information
  # But only members will see privileged information (via serializer logic)
  def show?
    # Allow viewing if coffee is active and roaster is active (public catalog)
    # OR if user is a member of the roaster (can see inactive coffees)
    (record.is_active? && record.roaster.active?) || 
    (user && user.member_of?(record.roaster))
  end
  
  # Only roaster members with editing privileges can create coffees
  def create?
    user && user.can_edit?(record.roaster)
  end
  
  # Only roaster members with editing privileges can update coffees
  def update?
    user && user.can_edit?(record.roaster)
  end
  
  # Only owners and managers can delete coffees
  def destroy?
    user && user.can_manage?(record.roaster)
  end
  
  # Only members can toggle active status
  def toggle_active?
    user && user.can_edit?(record.roaster)
  end
  
  # Only members can toggle featured status
  def toggle_featured?
    user && user.can_edit?(record.roaster)
  end
  
  # Only members can manage categories
  def manage_categories?
    user && user.can_edit?(record.roaster)
  end
end

