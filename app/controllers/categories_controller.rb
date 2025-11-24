class CategoriesController < ApplicationController
  # Authenticate user for all actions except index and show (public browsing)
  before_action :authenticate_user!, except: [ :index, :show ]
  before_action :set_roaster
  before_action :set_category, only: [ :show, :update, :destroy ]

  # GET /roasters/:roaster_id/categories
  # List all categories for a specific roaster
  # - Public users: See active categories from active roasters
  # - Members: See active categories + their roaster's inactive categories
  #
  # Query parameters:
  # - include_coffees: Include coffees in each category (true/false)
  def index
    # Scope categories to the specific roaster
    @categories = policy_scope(@roaster.categories)

    # Default ordering: by position
    @categories = @categories.by_position

    render json: CategorySerializer.new(@categories, {
      params: {
        current_user: current_user,
        include_coffees: params[:include_coffees] == "true"
      }
    }).serializable_hash, status: :ok
  end

  # GET /roasters/:roaster_id/categories/:id
  # Show details of a specific category within a roaster
  # - Public users: See public information only
  # - Members: See public + privileged information
  #
  # Query parameters:
  # - include_coffees: Include coffees in response (default: true for show)
  def show
    authorize @category

    render json: CategorySerializer.new(@category, {
      params: {
        current_user: current_user,
        include_coffees: params[:include_coffees] != "false" # default true for show
      }
    }).serializable_hash, status: :ok
  end

  # POST /roasters/:roaster_id/categories
  # Create a new category (MEMBERS ONLY - requires edit privileges)
  def create
    @category = @roaster.categories.build(category_params)
    authorize @category

    if @category.save
      render json: {
        message: "Category created successfully",
        category: CategorySerializer.new(@category, {
          params: { current_user: current_user }
        }).serializable_hash[:data][:attributes]
      }, status: :created
    else
      render json: { errors: @category.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /roasters/:roaster_id/categories/:id
  # Update category details (MEMBERS ONLY - requires edit privileges)
  def update
    authorize @category

    if @category.update(category_params)
      render json: {
        message: "Category updated successfully",
        category: CategorySerializer.new(@category, {
          params: { current_user: current_user }
        }).serializable_hash[:data][:attributes]
      }, status: :ok
    else
      render json: { errors: @category.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /roasters/:roaster_id/categories/:id
  # Delete a category (MEMBERS ONLY - requires management privileges)
  def destroy
    authorize @category

    @category.destroy
    render json: { message: "Category deleted successfully" }, status: :ok
  end

  private

  # Find the roaster first
  def set_roaster
    @roaster = Roaster.find(params[:roaster_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Roaster not found" }, status: :not_found
  end

  # Find the category within the roaster's scope
  def set_category
    @category = @roaster.categories.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Category not found for this roaster" }, status: :not_found
  end

  # Permitted parameters for category
  def category_params
    params.require(:category).permit(
      :name,
      :description,
      :color,
      :icon,
      :position,
      :is_active
    )
  end
end
