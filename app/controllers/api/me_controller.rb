class Api::MeController < Api::ApiController
  # Require authentication for all actions
  before_action :authenticate_user!

  # GET /users/
  # Returns information about the currently authenticated user
  # This endpoint allows users to retrieve their own profile information
  def show
    # Return user information in JSON format
    # We exclude sensitive information like encrypted_password, tokens, etc.
    render json: {
      id: current_user.id,
      email: current_user.email,
      name: current_user.name,
      provider: current_user.provider,
      profile_picture_url: current_user.profile_picture_url,
      preferred_grind_method: current_user.preferred_grind_method,
      preferred_roast_level: current_user.preferred_roast_level,
      preferred_bag_size: current_user.preferred_bag_size,
      confirmed_at: current_user.confirmed_at,
      created_at: current_user.created_at,
      updated_at: current_user.updated_at,
      is_roaster_member: !current_user.active_roaster_memberships.empty?
    }, status: :ok
  end
end
