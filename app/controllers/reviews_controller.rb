class ReviewsController < ApplicationController
  # Authenticate user for all actions except index and show (reviews are public)
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_review, only: [:show, :update, :destroy]
  
  # GET /reviews or GET /roasters/:roaster_id/reviews
  # List reviews (public endpoint)
  # Query parameters:
  # - roaster_id: Filter by roaster (or use nested route /roasters/:roaster_id/reviews)
  # - user_id: Filter by user (who wrote the review)
  # - min_rating: Filter by minimum rating
  # - page: Page number (default: 1)
  # - per_page: Items per page (default: 20, max: 100)
  def index
    authorize Review
    
    # Use policy scope to filter reviews based on user permissions
    @reviews = policy_scope(Review)
    
    # Apply filters
    # Handle nested route: /roasters/:roaster_id/reviews
    # Rails automatically passes roaster_id from nested routes
    @reviews = @reviews.where(roaster_id: params[:roaster_id]) if params[:roaster_id].present?
    @reviews = @reviews.where(user_id: params[:user_id]) if params[:user_id].present?
    @reviews = @reviews.min_rating(params[:min_rating]) if params[:min_rating].present?
    
    # Default ordering: most recent first
    @reviews = @reviews.recent
    
    # Pagination
    # Default: 20 items per page, maximum: 100 items per page
    per_page = if params[:per_page].present?
                  requested = params[:per_page].to_i
                  requested > 0 ? [requested, 100].min : 20
                else
                  20
                end
    @reviews = @reviews.page(params[:page] || 1).per(per_page)
    
    # Serialize the paginated collection
    serialized_data = ReviewSerializer.new(@reviews, { 
      params: { current_user: current_user } 
    }).serializable_hash
    
    # Add pagination metadata
    render json: {
      data: serialized_data[:data],
      meta: {
        pagination: {
          current_page: @reviews.current_page,
          per_page: @reviews.limit_value,
          total_pages: @reviews.total_pages,
          total_count: @reviews.total_count,
          next_page: @reviews.next_page,
          prev_page: @reviews.prev_page,
          first_page: @reviews.first_page?,
          last_page: @reviews.last_page?
        }
      }
    }, status: :ok
  end
  
  # POST /reviews
  # Create a new review (ONLY AUTHENTICATED USERS)
  # Expects JSON body with:
  # {
  #   "review": {
  #     "roaster_id": 1,
  #     "rating": 4.5,
  #     "comment": "Great coffee, excellent service!"
  #   }
  # }
  def create
    @review = current_user.reviews.build(review_params)
    authorize @review
    
    if @review.save
      render json: {
        message: "Review created successfully",
        review: ReviewSerializer.new(@review, { 
          params: { current_user: current_user } 
        }).serializable_hash[:data][:attributes]
      }, status: :created
    else
      render json: { errors: @review.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  # PATCH/PUT /reviews/:id
  # Update a review (ONLY THE AUTHOR)
  # Expects JSON body with:
  # {
  #   "review": {
  #     "rating": 5.0,
  #     "comment": "Updated comment"
  #   }
  # }
  def update
    authorize @review
    
    if @review.update(review_params)
      render json: {
        message: "Review updated successfully",
        review: ReviewSerializer.new(@review, { 
          params: { current_user: current_user } 
        }).serializable_hash[:data][:attributes]
      }, status: :ok
    else
      render json: { errors: @review.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  # DELETE /reviews/:id
  # Delete a review (ONLY THE AUTHOR)
  def destroy
    authorize @review
    
    if @review.destroy
      render json: { message: "Review deleted successfully" }, status: :ok
    else
      render json: { errors: @review.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  private
  
  def set_review
    @review = Review.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Review not found" }, status: :not_found
  end
  
  def review_params
    params.require(:review).permit(:roaster_id, :rating, :comment)
  end
end

