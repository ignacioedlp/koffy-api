class CoffeeVariantsController < ApplicationController
  # Authenticate user for all actions (only create is available)
  before_action :authenticate_user!
  before_action :set_roaster
  before_action :set_coffee
  
  # POST /roasters/:roaster_id/coffees/:coffee_id/variants
  # Create a new coffee variant (MEMBERS ONLY - requires edit privileges)
  # The variant belongs to a coffee within a specific roaster
  def create
    @variant = @coffee.coffee_variants.build(variant_params)
    authorize @variant
    
    if @variant.save
      render json: {
        message: "Coffee variant created successfully",
        variant: CoffeeVariantSerializer.new(@variant, { 
          params: { current_user: current_user } 
        }).serializable_hash[:data][:attributes]
      }, status: :created
    else
      render json: { errors: @variant.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  private
  
  # Find the roaster first
  def set_roaster
    @roaster = Roaster.find(params[:roaster_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Roaster not found" }, status: :not_found
  end
  
  # Find the coffee within the roaster's scope
  def set_coffee
    @coffee = @roaster.coffees.find(params[:coffee_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Coffee not found for this roaster" }, status: :not_found
  end
  
  # Permitted parameters for creating a variant
  def variant_params
    params.require(:coffee_variant).permit(
      :grind_type,
      :bag_size,
      :price,
      :stock
    )
  end
end

