# frozen_string_literal: true

module ProviderApi
  module Utils
    def safe_json_parse(json_string)
      @ruby_hash = JSON.parse(json_string)
    rescue JSON::ParserError => _error
      @ruby_hash = nil
    end
  end
end
