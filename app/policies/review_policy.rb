# frozen_string_literal: true

# Policy to authorize Review actions
class ReviewPolicy < ApplicationPolicy
  # Scope to filter reviews based on user permissions
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.nil?
        # Unauthenticated users can see all reviews (public information)
        scope.all
      else
        # Authenticated users can see all reviews
        # Reviews are public information
        scope.all
      end
    end
  end

  # Anyone can view the index (list of reviews)
  # Reviews are public information
  def index?
    true
  end

  # Anyone can view a review's details
  # Reviews are public information
  def show?
    true
  end

  # Only authenticated users can create reviews
  # A user can only create one review per roaster (enforced by model validation)
  def create?
    user.present?
  end

  # Only the user who created the review can update it
  def update?
    return false unless user.present?
    
    # User must be the author of the review
    record.user_id == user.id
  end

  # Only the user who created the review can delete it
  def destroy?
    return false unless user.present?
    
    # User must be the author of the review
    record.user_id == user.id
  end
end

