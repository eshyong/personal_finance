require "test_helper"

class ConfirmationsControllerTest < ActionDispatch::IntegrationTest
  test "should get confirm_email" do
    get confirmations_confirm_email_url
    assert_response :success
  end
end
