module Api
  class ApiController < ApplicationController
    # Base controller for all API endpoints
    # Add any API-wide configurations or before_actions here

    # Force JSON responses for all API endpoints
    respond_to :json

    # Ensure all API requests are processed as JSON
    before_action :set_default_format

    private

    def set_default_format
      request.format = :json
    end
  end
end
