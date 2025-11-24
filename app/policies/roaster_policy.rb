# frozen_string_literal: true

# Policy to authorize Roaster actions
class RoasterPolicy < ApplicationPolicy
  # Scope to filter roasters based on user permissions
  class Scope < ApplicationPolicy::Scope
    def resolve
      # All authenticated users can see active roasters (public catalog)
      # Coffee lovers can browse roasters to buy coffee
      # Members see the same list but with additional details in the serializer
      scope.where(active: true)
    end
  end

  # Anyone can view the index (list of roasters)
  # This allows coffee lovers to browse available roasters
  def index?
    true
  end

  # Any authenticated user can view a roaster's public information
  # But only members will see privileged information (via serializer logic)
  def show?
    # Allow viewing if roaster is active (public catalog)
    # OR if user is a member (can see inactive roasters they're part of)
    record.active? || user.member_of?(record)
  end

  # Any authenticated user can create a roaster
  # They will automatically become the owner
  def create?
    user.present?
  end

  # Only owners and managers can update roaster details
  def update?
    user.can_manage?(record)
  end

  # Only owners can delete a roaster
  def destroy?
    user.owner_of?(record)
  end

  # Only owners and managers can invite users to the roaster
  def invite_member?
    user.can_manage?(record)
  end

  # Only owners and managers can remove members
  def remove_member?
    user.can_manage?(record)
  end

  # Only owners can transfer ownership
  def transfer_ownership?
    user.owner_of?(record)
  end

  # Only owners and managers can change member roles
  def change_member_role?
    user.can_manage?(record)
  end

  # Owners, managers, and baristas can edit roaster content (products, inventory, etc.)
  def edit_content?
    user.can_edit?(record)
  end

  # Only owners can deactivate/activate the roaster
  def toggle_active?
    user.owner_of?(record)
  end

  # Users can view members if they are part of the roaster
  def view_members?
    user.member_of?(record)
  end
end
