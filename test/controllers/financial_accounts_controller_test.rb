require "test_helper"

class FinancialAccountsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get financial_accounts_show_url
    assert_response :success
  end

  test "should get index" do
    get financial_accounts_index_url
    assert_response :success
  end
end
