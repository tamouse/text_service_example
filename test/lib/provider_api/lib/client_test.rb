# frozen_string_literal: true

class ProviderApiTest < ActiveSupport::TestCase
  attr_reader :client, :provider

  setup do
    @provider = providers(:provider_1)
    @client = ::ProviderApi::Client.new(endpoint: provider.endpoint, callback: "https://www.example.com/code_test")
  end

  test "can initialize client with necessary information" do
    assert provider.endpoint, client.endpoint
  end

  test "post to endpoint with good phone number works as expected" do
    VCR.use_cassette('ProviderApiTest/post to endpoint with good phone number works as expected') do
      phone = "6125551212"
      message = "Testing the endpoint"
      client.post(phone_number: phone, message_body: message)
      refute_nil client.result
    end
  end

  test "using a bad phone number gives a 4xx error" do
    skip "Can't figure out how to force the endpoint to fail"
    VCR.use_cassette('ProviderApiTest/using a bad phone number gives a 4xx error') do |cass|
      client.post(phone_number: nil, message_body: nil)
      binding.pry
      refute_nil client.result
      assert_equal ProviderApi::Client::Result::Failure, client.result.class
      # refute client.succeeded?
    end
  end
end
