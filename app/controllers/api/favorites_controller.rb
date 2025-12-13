class Api::FavoritesController < Api::ApiController
  before_action :authenticate_user!

  # GET /favorites
  # Query parameters:
  # - type: Filter by favoritable type (coffee, roaster, coffee_variant)
  # - page: Page number (default: 1)
  # - per_page: Items per page (default: 20, max: 100)
  def index
    @favorites = current_user.favorites.includes(:favoritable)

    # Filter by type if specified
    if params[:type].present?
      case params[:type].downcase
      when "coffee"
        @favorites = @favorites.coffees
      when "roaster"
        @favorites = @favorites.roasters
      when "coffee_variant"
        @favorites = @favorites.coffee_variants
      end
    end

    # Default ordering: most recent first
    @favorites = @favorites.order(created_at: :desc)

    # Pagination
    # Default: 20 items per page, maximum: 100 items per page
    per_page = if params[:per_page].present?
                  requested = params[:per_page].to_i
                  requested > 0 ? [ requested, 100 ].min : 20
    else
                  20
    end
    @favorites = @favorites.page(params[:page] || 1).per(per_page)

    # Serialize the paginated collection
    serialized_data = FavoriteSerializer.new(@favorites).serializable_hash

    # Add pagination metadata
    render json: {
      data: serialized_data[:data],
      meta: {
        pagination: {
          current_page: @favorites.current_page,
          per_page: @favorites.limit_value,
          total_pages: @favorites.total_pages,
          total_count: @favorites.total_count,
          next_page: @favorites.next_page,
          prev_page: @favorites.prev_page,
          first_page: @favorites.first_page?,
          last_page: @favorites.last_page?
        }
      }
    }, status: :ok
  end

  # POST /favorites
  def create
    @favorite = current_user.favorites.build(favorite_params)

    if @favorite.save
      render json: @favorite, status: :created, include: [ :favoritable ]
    else
      render json: { errors: @favorite.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /favorites/:id
  def destroy
    @favorite = current_user.favorites.find(params[:id])
    @favorite.destroy
    head :no_content
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Favorite not found" }, status: :not_found
  end

  # DELETE /favorites/remove
  # Alternative endpoint to remove favorite by favoritable_type and favoritable_id
  def remove
    @favorite = current_user.favorites.find_by!(
      favoritable_type: params[:favoritable_type],
      favoritable_id: params[:favoritable_id]
    )
    @favorite.destroy
    head :no_content
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Favorite not found" }, status: :not_found
  end

  private

  def favorite_params
    params.require(:favorite).permit(:favoritable_type, :favoritable_id)
  end
end
