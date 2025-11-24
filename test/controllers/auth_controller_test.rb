require "test_helper"

class AuthControllerTest < ActionDispatch::IntegrationTest
  # Setup method to configure test environment
  def setup
    # Set a dummy GOOGLE_CLIENT_ID for tests (won't be used due to mocking)
    ENV["GOOGLE_CLIENT_ID"] ||= "test_client_id"
  end

  test "should authenticate with google id_token" do
    # Mock the Google ID token validator to avoid calling Google's API during tests
    validator_mock = Minitest::Mock.new
    validator_mock.expect :check, {
      "email" => "test@example.com",
      "sub" => "google_user_123",
      "name" => "Test User"
    }, [String, String, String]

    # Stub the validator creation
    GoogleIDToken::Validator.stub :new, validator_mock do
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
    # Mock the Google ID token validator to return nil (invalid token)
    validator_mock = Minitest::Mock.new
    validator_mock.expect :check, nil, [String, String, String]

    # Stub the validator creation
    GoogleIDToken::Validator.stub :new, validator_mock do
      # Make POST request with invalid id_token
      post auth_google_url, params: { id_token: "invalid_token" }, as: :json

      # Assert unauthorized response
      assert_response :unauthorized
      
      # Parse JSON response
      json_response = JSON.parse(response.body)
      
      # Assert error message
      assert_equal "Invalid Google token", json_response["error"]
    end
  end
end
