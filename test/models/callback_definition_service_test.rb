# frozen_string_literal: true

class CallbackDefinitionServiceTest < ActiveSupport::TestCase
  setup do
    ENV.delete('LOCAL_TUNNEL_HOST')
    ENV.delete('WEBHOOK_SITE')
  end
  
  test "gives a valid URL" do
    url = CallbackDefinitionService.callback
    refute_nil url

    begin
      URI.parse url
    rescue URI::InvalidURIError
      flunk "#{url} is not a URI 😜 "
    end

    assert_match 'localhost', url, "OOP! expected url to match 'localhost'"
  end

  test "uses ngrok form" do
    ENV['LOCAL_TUNNEL_HOST'] = 'abcdefg.ngrok.io'
    
    url = CallbackDefinitionService.callback
    refute_nil url

    begin
      URI.parse url
    rescue URI::InvalidURIError
      flunk "#{url} is not a URI 😜 "
    end

    assert_match 'ngrok.io', url, "OOP! expected url to match 'ngrok,io'"
  end

  test "uses webhook_site form" do
    ENV['WEBHOOK_SITE'] = 'https://webhook_site.com/asdflasdasdfasdfasdf'
    
    url = CallbackDefinitionService.callback
    refute_nil url

    begin
      URI.parse url
    rescue URI::InvalidURIError
      flunk "#{url} is not a URI 😜 "
    end

    assert_match 'webhook_site', url, "OOP! expected url to match 'webhook_site'"
  end
end
