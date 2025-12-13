class Api::CoffeesController < Api::ApiController
  # Authenticate user for all actions except index and show (public browsing)
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_roaster, only: [ :create, :update, :destroy ]
  before_action :set_coffee, only: [ :show, :update, :destroy ]

  # GET /coffees
  # List all coffees (PUBLIC)
  # - Public users: See active coffees from active roasters
  # - Members: See active coffees + their roaster's inactive coffees
  #
  # Query parameters:
  # - roaster_id: Filter by roaster
  # - category_id: Filter by category
  # - featured: Filter featured coffees (true/false)
  # - country: Filter by origin country
  # - roast_level: Filter by roast level
  # - process_method: Filter by process method
  # - include_variants: Include coffee variants in response (true/false)
  # - page: Page number (default: 1)
  # - per_page: Items per page (default: 20, max: 100)
  def index
    @coffees = policy_scope(Coffee)

    # Apply filters
    @coffees = @coffees.where("coffees.name ILIKE ?", "%#{params[:name]}%") if params[:name].present?
    @coffees = @coffees.where(coffees: { roaster_id: params[:roaster_id] }) if params[:roaster_id].present?
    @coffees = @coffees.in_category(params[:category_id]) if params[:category_id].present?
    @coffees = @coffees.featured if params[:featured] == "true"
    @coffees = @coffees.from_country(params[:country]) if params[:country].present?
    @coffees = @coffees.roast_level_filter(params[:roast_level]) if params[:roast_level].present?
    @coffees = @coffees.process_method_filter(params[:process_method]) if params[:process_method].present?


    # Default ordering: featured first, then recent
    @coffees = @coffees.order(featured: :desc, "coffees.created_at": :desc)

    # Pagination
    # Default: 20 items per page, maximum: 100 items per page
    per_page = if params[:per_page].present?
                  requested = params[:per_page].to_i
                  requested > 0 ? [ requested, 100 ].min : 20
    else
                  20
    end
    @coffees = @coffees.page(params[:page] || 1).per(per_page)

    # Serialize the paginated collection
    serialized_data = CoffeeSerializer.new(@coffees, {
      params: {
        current_user: current_user,
        include_variants: params[:include_variants] == "true"
      }
    }).serializable_hash

    # Add pagination metadata
    render json: {
      data: serialized_data[:data],
      meta: {
        pagination: {
          current_page: @coffees.current_page,
          per_page: @coffees.limit_value,
          total_pages: @coffees.total_pages,
          total_count: @coffees.total_count,
          next_page: @coffees.next_page,
          prev_page: @coffees.prev_page,
          first_page: @coffees.first_page?,
          last_page: @coffees.last_page?
        },
        filters: Rails.cache.fetch("coffees_index_filters", expires_in: 1.hour) do
          {
            roasters: Roaster.pluck(:id, :name).map { |id, name| { id: id, name: name } },
            categories: Category.pluck(:id, :name).map { |id, name| { id: id, name: name } },
            origin_countries: Coffee.distinct.pluck(:origin_country).compact,
            roast_levels: Coffee.distinct.pluck(:roast_level).compact,
            process_methods: Coffee.distinct.pluck(:process_method).compact
          }
        end
      }
    }, status: :ok
  end

  def show
    authorize @coffee

    render json: CoffeeSerializer.new(@coffee, {
      params: {
        current_user: current_user,
        include_variants: params[:include_variants] != "false" # default true for show
      }
    }).serializable_hash, status: :ok
  end

  def create
    @coffee = @roaster.coffees.build(coffee_params)
    authorize @coffee

    if @coffee.save
      render json: {
        message: "Coffee created successfully",
        coffee: CoffeeSerializer.new(@coffee, {
          params: { current_user: current_user, include_variants: true }
        }).serializable_hash[:data][:attributes]
      }, status: :created
    else
      render json: { errors: @coffee.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    authorize @coffee

    if @coffee.update(coffee_params)
      render json: {
        message: "Coffee updated successfully",
        coffee: CoffeeSerializer.new(@coffee, {
          params: { current_user: current_user, include_variants: true }
        }).serializable_hash[:data][:attributes]
      }, status: :ok
    else
      render json: { errors: @coffee.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @coffee

    @coffee.destroy
    render json: { message: "Coffee deleted successfully" }, status: :ok
  end

  private

  def set_roaster
    @roaster = Roaster.find_by!(slug: params[:roaster_slug])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Roaster not found" }, status: :not_found
  end

  def set_coffee
    if params[:roaster_slug].present?
      set_roaster
      @coffee = @roaster.coffees.find_by!(slug: params[:slug]) if @roaster
    else
      @coffee = Coffee.find_by!(slug: params[:slug])
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Coffee not found" }, status: :not_found
  end

  def coffee_params
    params.require(:coffee).permit(
      :name,
      :description,
      :origin_country,
      :varietal,
      :process_method,
      :roast_level,
      :flavor_notes,
      :is_active,
      :featured,
      images: [],
      category_ids: []
    )
  end
end
