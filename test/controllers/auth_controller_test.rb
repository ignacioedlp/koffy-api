require "test_helper"

class AuthControllerTest < ActionDispatch::IntegrationTest
  # Setup method to configure test environment
  def setup
    # Set a dummy GOOGLE_CLIENT_ID for tests (won't be used due to mocking)
    ENV["GOOGLE_CLIENT_ID"] ||= "test_client_id"
  end

  test "should authenticate with google id_token" do
    # Create a mock validator object that responds to check method
    # In Minitest, we use a simple object with the method we need
    validator_mock = Object.new
    def validator_mock.check(token, client_id, audience)
      {
        "email" => "test@example.com",
        "sub" => "google_user_123",
        "name" => "Test User"
      }
    end

    # Temporarily replace the new method to return our mock
    # Store the original method
    original_new = GoogleIDToken::Validator.method(:new)
    GoogleIDToken::Validator.define_singleton_method(:new) { |*args| validator_mock }

    begin
      # Make POST request with id_token parameter
      post auth_google_url, params: { id_token: "fake_google_id_token" }, as: :json

      # Assert successful response
      assert_response :success

      # Parse JSON response
      json_response = JSON.parse(response.body)

      # Assert response structure
      assert_equal "Successfully authenticated", json_response["message"]
      assert_not_nil json_response["user"]
      assert_equal "test@example.com", json_response["user"]["email"]
      assert_equal "Test User", json_response["user"]["name"]

      # Verify that a user was created or found
      user = User.find_by(email: "test@example.com")
      assert_not_nil user
      assert_equal "google", user.provider
      assert_equal "google_user_123", user.uid
    ensure
      # Restore the original method
      GoogleIDToken::Validator.define_singleton_method(:new, &original_new)
    end
  end

  test "should return error when id_token is missing" do
    # Make POST request without id_token
    post auth_google_url, params: {}, as: :json

    # Assert bad request response
    assert_response :bad_request

    # Parse JSON response
    json_response = JSON.parse(response.body)

    # Assert error message
    assert_equal "id_token is required", json_response["error"]
  end

  test "should return error when id_token is invalid" do
    # Create a mock validator that returns nil (invalid token)
    validator_mock = Object.new
    def validator_mock.check(token, client_id, audience)
      nil
    end

    # Temporarily replace the new method to return our mock
    # Store the original method
    original_new = GoogleIDToken::Validator.method(:new)
    GoogleIDToken::Validator.define_singleton_method(:new) { |*args| validator_mock }

    begin
      # Make POST request with invalid id_token
      post auth_google_url, params: { id_token: "invalid_token" }, as: :json

      # Assert unauthorized response
      assert_response :unauthorized

      # Parse JSON response
      json_response = JSON.parse(response.body)

      # Assert error message
      assert_equal "Invalid Google token", json_response["error"]
    ensure
      # Restore the original method
      GoogleIDToken::Validator.define_singleton_method(:new, &original_new)
    end
  end
end
