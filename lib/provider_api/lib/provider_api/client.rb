# frozen_string_literal: true

module ProviderApi
  class Client

    include ProviderApi::Utils
    
    attr_reader :request_body           # Message request_body of the request
    attr_reader :callback               # The URL to tell the provider to callback after the message iks sent
    attr_reader :endpoint               # Endpoint for provider
    attr_reader :response               # Holds the response from the endpoint
    attr_accessor :result               # Result of the actions, Success or Failure

    def initialize(endpoint:, callback:)
      @endpoint = endpoint
      @callback = callback
    end

    def post(phone_number:, message_body:)
      prepare_body(phone_number: phone_number, message_body: message_body)
      @response = client.post(endpoint) do |req|
        req.body = request_body.to_json
      end
      process_response
      self
    end

    def success?
      result.class.name.demodulize == "Success"
    end

    def client
      return @client if defined?(@client)

      @client = conn = Faraday.new(
        headers: { 'Content-Type' => 'application/json' }
      )
    end

    def prepare_body(phone_number:, message_body:)
      @request_body = {
        to_number: phone_number,
        message: message_body,
        callback_url: callback
      }
    end

    def process_response
      self.result =
        if (200..399).cover?(response.status)
          Result::Success.new(status_code: response.status, parsed_body: safe_json_parse(response.body), raw_body: response.body, timestamp: Time.current)
        elsif (400..599).cover?(response.status)
          Result::Failure.new(status_code: response.status, parsed_body: safe_json_parse(response.body), raw_body: response.body, timestamp: Time.current)
        else
          nil
        end
    end
  end
end
