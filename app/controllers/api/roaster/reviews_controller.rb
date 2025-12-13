class Api::Roaster::ReviewsController < Api::Roaster::RoasterController
  # GET /reviews or GET /roasters/:roaster_id/reviews
  # List reviews (public endpoint)
  # Query parameters:
  # - user_id: Filter by user (who wrote the review)
  # - min_rating: Filter by minimum rating
  # - page: Page number (default: 1)
  # - per_page: Items per page (default: 20, max: 100)
  def index
    authorize @roaster

    @reviews = ReviewPolicy::RoasterScope.new(current_user, Review, @roaster).resolve.includes(:user, :roaster)

    @reviews = @reviews.where(user_id: params[:user_id]) if params[:user_id].present?
    @reviews = @reviews.min_rating(params[:min_rating]) if params[:min_rating].present?

    # Default ordering: most recent first
    @reviews = @reviews.recent

    # Pagination
    # Default: 20 items per page, maximum: 100 items per page
    per_page = if params[:per_page].present?
                  requested = params[:per_page].to_i
                  requested > 0 ? [ requested, 100 ].min : 20
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
end
