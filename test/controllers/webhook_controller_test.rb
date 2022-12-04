require "test_helper"

class WebhookControllerTest < ActionDispatch::IntegrationTest
  attr_reader :msg

  setup do
    guid = 'anything-it-doesnt-matter'
    @msg = messages(:message_1)
    msg.update_column(:message_guid, guid)
  end
  
  test "post a valid payload" do
    params = {
      status: 'delivered',
      message_id: msg.message_guid
    }
    
    post '/delivery_status', params: params.to_json, headers: headers
    assert_response :success
    msg.reload
    
    assert_equal 'delivered', msg.status
    assert_equal 'delivered', msg.phone.status
  end

  def headers
    {
      "Content-type": "application/json"
    }
  end

end
