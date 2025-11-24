# frozen_string_literal: true

class CategoryPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user
        scope.joins(:roaster)
             .where(
               "(categories.is_active = ? AND roasters.active = ?) OR 
                roasters.id IN (?)",
               true, 
               true, 
               user.roasters.pluck(:id)
             )
      else
        # Non-authenticated users can only see active categories from active roasters
        scope.joins(:roaster)
             .where(categories: { is_active: true }, roasters: { active: true })
      end
    end
  end
  
  # Anyone can view the index (list of categories)
  # This allows coffee lovers to browse and filter by categories
  def index?
    true
  end
  
  # Any user can view a category's public information
  # But only members will see privileged information (via serializer logic)
  def show?
    # Allow viewing if category is active and roaster is active (public catalog)
    # OR if user is a member of the roaster (can see inactive categories)
    (record.is_active? && record.roaster.active?) || 
    (user && user.member_of?(record.roaster))
  end
  
  # Only roaster members with editing privileges can create categories
  def create?
    user && user.can_edit?(record.roaster)
  end
  
  # Only roaster members with editing privileges can update categories
  def update?
    user && user.can_edit?(record.roaster)
  end
  
  # Only owners and managers can delete categories
  def destroy?
    user && user.can_manage?(record.roaster)
  end
  
  # Only members can toggle active status
  def toggle_active?
    user && user.can_edit?(record.roaster)
  end
  
  # Only members can reorder categories
  def reorder?
    user && user.can_edit?(record.roaster)
  end
end

