class RoasterMembersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_roaster
  
  # GET /roasters/:roaster_id/members
  # List all members of a roaster
  def index
    authorize @roaster, :view_members?
    
    members = @roaster.roaster_memberships.includes(:user).active
    
    # Serialize the memberships using the serializer
    serialized_members = RoasterMembershipSerializer.new(members).serializable_hash
    
    render json: {
      roaster_id: @roaster.id,
      roaster_name: @roaster.name,
      members: serialized_members[:data].map { |member| member[:attributes] }
    }, status: :ok
  end
  
  # POST /roasters/:roaster_id/members
  # Add a member to the roaster
  def create
    authorize @roaster, :invite_member?
    
    user = User.find_by(id: params[:user_id])
    
    if user.nil?
      return render json: { error: "User not found" }, status: :not_found
    end
    
    # Check if user is already a member
    if @roaster.has_member?(user)
      return render json: { error: "User is already a member of this roaster" }, status: :unprocessable_entity
    end
    
    membership = @roaster.roaster_memberships.new(
      user: user,
      role: params[:role] || :member,
      salary: params[:salary],
      currency: params[:currency] || 'USD',
      salary_period: params[:salary_period] || 'monthly'
    )
    
    if membership.save
      render json: {
        message: "Member added successfully",
        membership: RoasterMembershipSerializer.new(membership).serializable_hash[:data][:attributes]
      }, status: :created
    else
      render json: { errors: membership.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  # DELETE /roasters/:roaster_id/members/:id
  # Remove a member from the roaster
  def destroy
    authorize @roaster, :remove_member?
    
    user = User.find_by(id: params[:id])
    
    if user.nil?
      return render json: { error: "User not found" }, status: :not_found
    end
    
    membership = @roaster.roaster_memberships.find_by(user: user)
    
    if membership.nil?
      return render json: { error: "User is not a member of this roaster" }, status: :not_found
    end
    
    # Authorize the membership deletion
    authorize membership, :destroy?
    
    membership.deactivate!
    render json: { message: "Member removed successfully" }, status: :ok
  end
  
  # PATCH /roasters/:roaster_id/members/:id
  # Update a member's role and information in the roaster
  def update
    authorize @roaster, :change_member_role?
    
    user = User.find_by(id: params[:id])
    
    if user.nil?
      return render json: { error: "User not found" }, status: :not_found
    end
    
    membership = @roaster.roaster_memberships.find_by(user: user)
    
    if membership.nil?
      return render json: { error: "User is not a member of this roaster" }, status: :not_found
    end
    
    # Authorize the membership update
    authorize membership, :update?
    
    # Build update params (only include provided values)
    update_params = {}
    update_params[:role] = params[:role] if params[:role].present?
    update_params[:salary] = params[:salary] if params.key?(:salary)
    update_params[:currency] = params[:currency] if params[:currency].present?
    update_params[:salary_period] = params[:salary_period] if params[:salary_period].present?
    
    if membership.update(update_params)
      # Usamos el serializer para devolver la membresía actualizada
      render json: {
        message: "Member information updated successfully",
        membership: RoasterMembershipSerializer.new(membership).serializable_hash[:data][:attributes]
      }, status: :ok
    else
      render json: { errors: membership.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  private
  
  # Find the roaster based on roaster_id parameter
  def set_roaster
    @roaster = Roaster.find(params[:roaster_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Roaster not found" }, status: :not_found
  end
end

