
    class Api::Roaster::CategoriesController < Api::Roaster::RoasterController
      before_action :set_category, only: [ :show, :update, :destroy ]

    # GET /admin/roasters/:roaster_slug/categories
    # List all categories for a specific roaster (MEMBERS ONLY)
    #
    # Query parameters:
    # - include_coffees: Include coffees in each category (true/false)
    def index
      # Authorize the roaster for index action
      authorize @roaster, :index?, policy_class: CategoryPolicy

      # Scope categories to the specific roaster
      @categories = policy_scope(Category)

      # Default ordering: by position
      @categories = @roaster.categories.by_position

      render json: CategorySerializer.new(@categories, {
        params: {
          current_user: current_user,
          include_coffees: params[:include_coffees] == "true"
        }
      }).serializable_hash, status: :ok
    end

    # GET /admin/roasters/:roaster_slug/categories/:id
    # Show details of a specific category within a roaster (MEMBERS ONLY)
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

    # POST /admin/roasters/:roaster_slug/categories
    # Create a new category (MEMBERS ONLY - requires edit privileges)
    def create
      @category = @roaster.categories.build(category_params.merge(roaster_id: @roaster.id))
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

    # PATCH/PUT /admin/roasters/:roaster_slug/categories/:id
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

    # DELETE /admin/roasters/:roaster_slug/categories/:id
    # Delete a category (MEMBERS ONLY - requires management privileges)
    def destroy
      authorize @category

      @category.destroy
      render json: { message: "Category deleted successfully" }, status: :ok
    end

    private

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
