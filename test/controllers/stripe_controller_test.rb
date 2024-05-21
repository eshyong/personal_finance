require "test_helper"

class StripeControllerTest < ActionDispatch::IntegrationTest
  test "should get create_financial_connections_session" do
    get stripe_create_financial_connections_session_url
    assert_response :success
  end
end
