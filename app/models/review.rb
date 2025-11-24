class Review < ApplicationRecord
  # Include Ransackable concern for ActiveAdmin search functionality
  include Ransackable
  
  # Associations
  # A review belongs to a user (the reviewer)
  belongs_to :user
  
  # A review belongs to a roaster (the reviewed entity)
  belongs_to :roaster
  
  # Validations
  # Rating must be present and between 0 and 5 (with 2 decimal places)
  validates :rating, presence: true, 
                     numericality: { 
                       greater_than_or_equal_to: 0, 
                       less_than_or_equal_to: 5 
                     }
  
  # Comment is optional but if provided, should have a reasonable length
  validates :comment, length: { maximum: 2000 }, allow_blank: true
  
  # A user can only review a roaster once (enforced at database level with unique index)
  validates :user_id, uniqueness: { 
    scope: :roaster_id,
    message: 'has already reviewed this roaster'
  }
  
  # Scopes
  # Scope to find reviews by rating
  scope :by_rating, ->(rating) { where(rating: rating) }
  
  # Scope to find reviews with minimum rating
  scope :min_rating, ->(min) { where('rating >= ?', min) }
  
  # Scope to find recent reviews (newest first)
  scope :recent, -> { order(created_at: :desc) }
  
  # Scope to find reviews by user
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  
  # Scope to find reviews by roaster
  scope :by_roaster, ->(roaster_id) { where(roaster_id: roaster_id) }
  
  # Callback to update roaster's average rating after review is saved
  after_save :update_roaster_average_rating
  after_destroy :update_roaster_average_rating
  
  private
  
  # Update the roaster's average rating based on all reviews
  # This is called automatically after a review is saved or destroyed
  def update_roaster_average_rating
    # Calculate the average rating from all reviews for this roaster
    reviews = Review.where(roaster_id: roaster_id)
    
    if reviews.any?
      # Calculate average rating (sum of all ratings / count of reviews)
      average = reviews.sum(:rating).to_f / reviews.count
      # Round to 2 decimal places
      average = (average * 100).round / 100.0
    else
      # If no reviews, set average to 0
      average = 0.0
    end
    
    # Update the roaster's average_rating field
    roaster.update_column(:average_rating, average)
  end
end

