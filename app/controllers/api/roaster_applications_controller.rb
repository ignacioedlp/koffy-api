class Api::RoasterApplicationsController < Api::ApiController
  def create
    @roaster_application = RoasterApplication.new(roaster_application_params)

    if @roaster_application.save
      render json: { message: "Roaster application submitted successfully." }, status: :created
    else
      render json: @roaster_application.errors, status: :unprocessable_entity
    end
  end

  private

  def roaster_application_params
    params.require(:roaster_application).permit(:email, :roaster_name, :full_name, :comment, :website_url, :phone_number, :type_of_business)
  end
end
