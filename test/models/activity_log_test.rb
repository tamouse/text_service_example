# frozen_string_literal: true

require "test_helper"

class ActivityLogTest < ActiveSupport::TestCase
  test "provider can add a log entry" do
    provider = providers(:provider_1)
    assert provider.activity_logs.create(success: true)
    log = provider.activity_logs.last
    assert_equal provider.class.name, log.loggable_type
    assert_equal provider.id, log.loggable_id
  end

  test "message can add a log entry" do
    message = messages(:message_1)
    assert message.activity_logs.create(success: true)
    log = message.activity_logs.last
    assert_equal message.class.name, log.loggable_type
    assert_equal message.id, log.loggable_id
  end

  test "phone can add a log entry" do
    phone = phones(:phone_1)
    assert phone.activity_logs.create(success: true)
    log = phone.activity_logs.last
    assert_equal phone.class.name, log.loggable_type
    assert_equal phone.id, log.loggable_id
  end
end
