class ApplicationController < ActionController::Base
  # Include Pundit for authorization
  include Pundit::Authorization
  
  # Skip CSRF protection for API endpoints
  # This allows the application to work as an API while supporting ActiveAdmin
  protect_from_forgery with: :null_session
  
  # Support both HTML (for ActiveAdmin) and JSON (for API endpoints)
  # Rails will automatically choose the correct format based on the request
  respond_to :html, :json
  
  # Handle authorization errors
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  
  private
  
  def user_not_authorized
    respond_to do |format|
      format.json { render json: { error: 'You are not authorized to perform this action' }, status: :forbidden }
      format.html { redirect_to(request.referrer || root_path, alert: 'You are not authorized to perform this action.') }
    end
  end
end
