# frozen_string_literal: true

module Api
  module V1
    class SendMessagexsControllerTest < ActionDispatch::IntegrationTest
      attr_accessor :phone_number, :message_body, :headers, :params

      setup do
        @phone_number = '8005551212'
        @message_body = 'Test message'
        @headers = {
          "Content-type": "application/json"
        }
        @params = {
          phone_number: phone_number,
          message_body: message_body
        }
      end

      test "posting with phone_number and message_body " do
        VCR.use_cassette('SendMessagexsControllerTest/posting with phone_number and message_body') do |cassette|
          post '/api/v1/send', xhr: true, params: params.to_json, headers: headers

          assert_equal 200, response.status, "Oops! 200 is not equal to response.status"
          assert_match 'message_id', response.body, "OOP! expected response.body to match 'message_id'"

          returned_info = JSON.parse(response.body) rescue {}
          message_guid = returned_info.dig('message_id')
          message = Message.find_by(message_guid: message_guid)
          refute_nil message
        end
      end

      test "sending with blank fields" do
        VCR.use_cassette('SendMessagexsControllerTest/sending with blank fields', :record => :new_episodes) do |cassette|
          post '/api/v1/send', xhr: true, params: params.merge(phone_number: '').to_json, headers: headers
          assert_equal 422, response.status, "Oops! expected 422 is not equal to response.status: #{response.status}"
          assert_match 'error', response.body, "OOP! expected response.body to match 'error'"
        end
      end
    end
  end
end
