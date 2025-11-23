require "test_helper"

class AuthControllerTest < ActionDispatch::IntegrationTest
  test "should get google" do
    get auth_google_url
    assert_response :success
  end
end
