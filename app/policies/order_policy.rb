# frozen_string_literal: true

# Policy to authorize Order actions
class OrderPolicy < ApplicationPolicy
  # Scope to filter orders based on user permissions
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.nil?
        # Unauthenticated users cannot see any orders
        scope.none
      elsif user.coffee_lover?
        # Coffee lovers can only see their own orders
        scope.where(user_id: user.id)
      else
        # Roaster members can see:
        # 1. Orders they placed as customers (their own orders)
        # 2. Orders for roasters they are members of
        scope.where(
          "user_id = ? OR roaster_id IN (?)",
          user.id,
          user.active_roasters.pluck(:id)
        )
      end
    end
  end

  # Users can view the index if they are authenticated
  def index?
    user.present?
  end

  # Users can view an order if:
  # 1. They are the customer (user_id matches)
  # 2. OR they are a member of the roaster assigned to the order
  def show?
    return false unless user.present?
    
    # User is the customer
    return true if record.user_id == user.id
    
    # User is a member of the roaster
    user.member_of?(record.roaster)
  end

  # Only coffee lovers can create orders
  # (Roaster members cannot create orders - they manage them)
  def create?
    user.present? && user.coffee_lover?
  end

  # Only members of the roaster assigned to the order can update it
  # The user must have editing privileges (owner, manager, or barista)
  def update?
    return false unless user.present?
    
    # User must be a member of the roaster with editing privileges
    user.can_edit?(record.roaster)
  end

  # Only members of the roaster can destroy orders
  def destroy?
    return false unless user.present?
    
    # Only owners and managers can delete orders
    user.can_manage?(record.roaster)
  end
end

