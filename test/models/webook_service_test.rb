# frozen_string_literal: true

require "test_helper"

class WebookServiceTest < ActiveSupport::TestCase
  attr_reader :msg

  i_suck_and_my_tests_are_order_dependent!

  setup do
    @msg = messages(:message_1)
  end

  test "payload with missing paramters" do
    payload = {}
    assert_raises ArgumentError do
      WebhookService.new(**payload)
    end
  end

  test "payload with empty paramters" do
    payload = { status: '', message_guid: ''}
    service = WebhookService.new(**payload)
    refute service.valid?, "Oops! expected service to be valid"
  end

  test "payload with filled paramters" do
    status = 'donotcare'
    message_guid = 'made-up-it-does-not-matter'
    msg.update_column(:message_guid, message_guid)
    payload = { status: status, message_guid: message_guid }
    service = WebhookService.new(**payload)
    assert service.valid?, "Oops! expected service to be valid"
  end

  test "payload with delivered status" do
    status = 'delivered'
    message_guid = 'made-up-it-does-not-matter'
    msg.update_column(:message_guid, message_guid)

    payload = { status: status, message_guid: message_guid }
    service = WebhookService.new(**payload)
    service.process_webhook

    msg.reload

    assert msg.id == service.message.id, "Oops! msg.id is not equal to service.message.id"
    assert status == service.message.status, "Oops! status is not equal to service.message.status"

    last_log = service.message.activity_logs.order(created: :asc).last
    assert last_log.success, "Oops! expected last message log success to be true"

    phone = service.message.phone
    assert phone.persisted?, "Oops! expected phone to be persisted"

    last_log = phone.activity_logs.order(created_at: :asc).last
    assert last_log.success, "Oops! expected last phone log success to be true"
  end

  test "payload with failed status" do
    status = 'failed'
    message_guid = 'made-up-it-does-not-matter'
    msg.update_column(:message_guid, message_guid)

    payload = { status: status, message_guid: message_guid }
    service = WebhookService.new(**payload)
    service.process_webhook

    msg.reload
    assert_equal msg.id, service.message.id, "Oops! msg.id is not equal to service.message.id"
    assert_equal status, service.message.status, "Oops! status is not equal to service.message.status"

    last_log = service.message.activity_logs.order(created: :asc).last
    refute last_log.success, "Oops! expected last message log success to be false"

    phone = service.message.phone
    assert phone.persisted?, "Oops! expected phone to be persisted"

    last_log = phone.activity_logs.order(created_at: :asc).last
    assert last_log.success, "Oops! expected last phone log success to be true"
  end

  test "payload with invalid status" do
    status = 'invalid'
    message_guid = 'made-up-it-does-not-matter'
    msg.update_column(:message_guid, message_guid)

    payload = { status: status, message_guid: message_guid }
    service = WebhookService.new(**payload)
    service.process_webhook

    msg.reload
    assert_equal msg.id, service.message.id, "Oops! msg.id is not equal to service.message.id"
    assert_equal status, service.message.status, "Oops! status is not equal to service.message.status"

    last_log = service.message.activity_logs.order(created: :asc).last
    refute last_log.success, "Oops! expected last message log success to be false"

    phone = service.message.phone
    assert phone.persisted?, "Oops! expected phone to be persisted"

    last_log = phone.activity_logs.order(created_at: :asc).last
    refute last_log.success, "Oops! expected last phone log success to be false"
  end
end
