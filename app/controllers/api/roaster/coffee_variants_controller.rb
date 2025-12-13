class Api::Roaster::CoffeeVariantsController < Api::Roaster::RoasterController
  before_action :set_coffee_variant

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

  def update
    authorize @variant

    if @variant.update(variant_params)
      render json: {
        message: "Coffee variant updated successfully",
        variant: CoffeeVariantSerializer.new(@variant, {
          params: { current_user: current_user }
        }).serializable_hash[:data][:attributes]
      }, status: :ok
    else
      render json: { errors: @variant.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @variant

    if @variant.destroy
      render json: { message: "Coffee variant deleted successfully" }, status: :ok
    else
      render json: { errors: @variant.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  # Find the coffee and variant within the roaster's scope
  def set_coffee_variant
    if params[:coffee_id].present?
      @coffee = @roaster.coffees.find(params[:coffee_id])
      @variant = params[:id].present? ? @coffee.coffee_variants.find(params[:id]) : nil
    elsif params[:id].present?
      # If only variant ID is provided, find it through the roaster's coffees
      @variant = CoffeeVariant.joins(:coffee).where(coffees: { roaster_id: @roaster.id }).find(params[:id])
      @coffee = @variant.coffee
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Coffee or variant not found for this roaster" }, status: :not_found
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
