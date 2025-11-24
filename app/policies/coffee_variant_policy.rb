# frozen_string_literal: true

class CoffeeVariantPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user
        scope.joins(coffee: :roaster)
             .where(
               "(coffees.is_active = ? AND roasters.active = ?) OR 
                roasters.id IN (?)",
               true, 
               true, 
               user.roasters.pluck(:id)
             )
      else
        # Non-authenticated users can only see variants from active coffees and active roasters
        scope.joins(coffee: :roaster)
             .where(coffees: { is_active: true }, roasters: { active: true })
      end
    end
  end
  
  # Anyone can view the index (list of variants)
  # This allows coffee lovers to browse available variants and prices
  def index?
    true
  end
  
  # Any user can view a variant's public information
  # But only members will see privileged information (exact stock) via serializer
  def show?
    # Allow viewing if coffee is active and roaster is active (public catalog)
    # OR if user is a member of the roaster (can see variants from inactive coffees)
    (record.coffee.is_active? && record.coffee.roaster.active?) || 
    (user && user.member_of?(record.coffee.roaster))
  end
  
  # Only roaster members with editing privileges can create variants
  def create?
    user && user.can_edit?(record.coffee.roaster)
  end
  
  # Only roaster members with editing privileges can update variants
  def update?
    user && user.can_edit?(record.coffee.roaster)
  end
  
  # Only owners and managers can delete variants
  def destroy?
    user && user.can_manage?(record.coffee.roaster)
  end
  
  # Only members can manage stock
  def manage_stock?
    user && user.can_edit?(record.coffee.roaster)
  end
  
  # Only members can add stock
  def add_stock?
    user && user.can_edit?(record.coffee.roaster)
  end
  
  # Only members can reduce stock
  def reduce_stock?
    user && user.can_edit?(record.coffee.roaster)
  end
end

