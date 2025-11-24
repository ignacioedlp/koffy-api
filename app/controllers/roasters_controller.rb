class RoastersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_roaster, only: [:show, :update, :destroy]
  
  # GET /roasters
  # List all active roasters (public catalog)
  # - Coffee lovers: See basic info (name, location, description) for browsing
  # - Members: See same list but with additional fields (user_role, is_member)
  def index
    @roasters = policy_scope(Roaster)
    render json: RoasterSerializer.new(@roasters, { 
      params: { current_user: current_user } 
    }).serializable_hash, status: :ok
  end
  
  # GET /roasters/:id
  # Show details of a specific roaster
  # - Coffee lovers: See public info only (catalog view for shopping)
  # - Members: See public info + privileged info (user_role, member stats)
  def show
    authorize @roaster
    
    render json: RoasterSerializer.new(@roaster, { 
      params: { current_user: current_user, include_members: true } 
    }).serializable_hash, status: :ok
  end
  
  # POST /roasters
  # Create a new roaster (user becomes the owner automatically)
  def create
    @roaster = Roaster.new(roaster_params)
    authorize @roaster
    
    if @roaster.save
      # Create membership for the creator as owner
      @roaster.roaster_memberships.create!(user: current_user, role: :owner)
      
      render json: {
        message: "Roaster created successfully",
        roaster: RoasterSerializer.new(@roaster, { 
          params: { current_user: current_user } 
        }).serializable_hash[:data][:attributes]
      }, status: :created
    else
      render json: { errors: @roaster.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  # PATCH/PUT /roasters/:id
  # Update roaster details
  def update
    authorize @roaster
    
    if @roaster.update(roaster_params)
      render json: {
        message: "Roaster updated successfully",
        roaster: RoasterSerializer.new(@roaster, { 
          params: { current_user: current_user } 
        }).serializable_hash[:data][:attributes]
      }, status: :ok
    else
      render json: { errors: @roaster.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  # DELETE /roasters/:id
  # Delete a roaster (only owner can do this)
  def destroy
    authorize @roaster
    
    @roaster.destroy
    render json: { message: "Roaster deleted successfully" }, status: :ok
  end
  
  private
  
  def set_roaster
    @roaster = Roaster.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Roaster not found" }, status: :not_found
  end
  
  def roaster_params
    params.require(:roaster).permit(:name, :location, :description, :active)
  end
end
