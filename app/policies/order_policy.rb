# frozen_string_literal: true

# Policy to authorize Order actions
class OrderPolicy < ApplicationPolicy
  # Scope to filter orders based on user permissions
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.nil?
        scope.none
      else
        # Por defecto, solo órdenes propias
        scope.where(user_id: user.id)
      end
    end
  end

  # Scope para miembros de roaster (usado solo en el endpoint de roaster)
  class RoasterScope < ApplicationPolicy::Scope
    def resolve
      if user.nil?
        scope.none
      else
        roaster_ids = user.active_roasters.pluck(:id)
        if roaster_ids.empty?
          scope.where(user_id: user.id)
        else
          scope.where("user_id = ? OR roaster_id IN (?)", user.id, roaster_ids)
        end
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

  # Users can update an order if:
  # 1. They are the customer AND the order is pending
  # 2. OR they are a member of the roaster with editing privileges
  def update?
    return false unless user.present?

    # Customer can edit their own order if it's pending
    return true if record.user_id == user.id && record.status == "pending"

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
