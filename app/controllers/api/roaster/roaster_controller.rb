module Api
  module Roaster
    class RoasterController < ApplicationController
      before_action :set_roaster

      private

      def set_roaster
        @roaster = current_user.roaster # o current_user.roaster_membership&.roaster
        head :forbidden unless @roaster
      end
    end
  end
end
