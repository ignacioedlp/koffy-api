class AuthController < ApplicationController
  # Skip CSRF verification for API endpoints
  skip_before_action :verify_authenticity_token, only: [:google]

  # POST /auth/google
  # Expects a JSON body with: { "id_token": "google_id_token_here" }
  def google
    begin
      # Extract the id_token from request
      id_token = params[:id_token]
      
      if id_token.blank?
        return render json: { error: 'id_token is required' }, status: :bad_request
      end

      # Verify the Google ID token
      validator = GoogleIDToken::Validator.new
      payload = validator.check(
        id_token,
        ENV['GOOGLE_CLIENT_ID'],      # You'll need to set this
        ENV['GOOGLE_CLIENT_ID']        # audience parameter
      )

      if payload.nil?
        return render json: { error: 'Invalid Google token' }, status: :unauthorized
      end

      # Extract user information from the payload
      email = payload['email']
      uid = payload['sub']
      name = payload['name']

      # Find or create user
      user = User.from_google(email: email, uid: uid, name: name)

      # Generate JWT token for the user
      # devise-jwt will automatically add the token to the response headers
      sign_in(user)

      # Return user information and success message
      render json: {
        message: 'Successfully authenticated',
        user: {
          id: user.id,
          email: user.email,
          name: user.name,
        }
      }, status: :ok

    rescue GoogleIDToken::ValidationError => e
      render json: { error: "Google token validation failed: #{e.message}" }, status: :unauthorized
    rescue StandardError => e
      render json: { error: "Authentication failed: #{e.message}" }, status: :internal_server_error
    end
  end

  # POST /login
  # Standard Devise login endpoint (optional, for email/password login)
  def login
    user = User.find_by(email: params[:email])

    if user&.valid_password?(params[:password])
      sign_in(user)
      render json: {
        message: 'Logged in successfully',
        user: {
          id: user.id,
          email: user.email,
          name: user.name,
        }
      }, status: :ok
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end

  # DELETE /logout
  # Revoke JWT token
  def logout
    if current_user
      sign_out(current_user)
      render json: { message: 'Logged out successfully' }, status: :ok
    else
      render json: { error: 'Not logged in' }, status: :unauthorized
    end
  end
end
