require "test_helper"

class PhonesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get phones_url
    assert_response :success
  end
end
