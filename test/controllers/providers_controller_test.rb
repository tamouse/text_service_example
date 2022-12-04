require "test_helper"

class ProvidersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get providers_url
    assert_response :success
  end
end
