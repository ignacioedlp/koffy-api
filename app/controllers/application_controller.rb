class ApplicationController < ActionController::Base
  # Skip CSRF protection for API endpoints
  # This allows the application to work as an API while supporting ActiveAdmin
  protect_from_forgery with: :null_session
  
  # Support both HTML (for ActiveAdmin) and JSON (for API endpoints)
  # Rails will automatically choose the correct format based on the request
  respond_to :html, :json
end
