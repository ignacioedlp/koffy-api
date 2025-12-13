# frozen_string_literal: true

class CategoryPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none unless user
      scope.where(roaster_id: user.roaster.id)
    end
  end

  def index?
    user && user.member_of?(record)
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
