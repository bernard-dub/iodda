require "test_helper"

class ProceduresControllerTest < ActionDispatch::IntegrationTest
  test "should get list" do
    get procedures_list_url
    assert_response :success
  end

  test "should get details" do
    get procedures_details_url
    assert_response :success
  end
end
