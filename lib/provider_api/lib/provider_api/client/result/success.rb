module ProviderApi
  class Client
    module Result
      class Success
        attr_reader :status_code, :parsed_body, :raw_body, :timestamp

        def initialize(status_code:, parsed_body:, raw_body:, timestamp:)
          @status_code = status_code
          @parsed_body = parsed_body
          @raw_body = raw_body
          @timestamp = timestamp
        end

        def to_s
          "#{self.class.name} status_code=#{status_code} timestamp=#{timestamp} raw_body=#{raw_body[0,20]}#{raw_body.length > 20 ? '...' : ''}"
        end
      end
    end
  end
end
