# frozen_string_literal: true

class ProviderApiTest < ActiveSupport::TestCase

  test "Gives the version" do
    assert_equal "0.1.0", ProviderApi::VERSION
  end

end
