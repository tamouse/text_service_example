# frozen_string_literal: true

class SendMessageServiceTest < ActiveSupport::TestCase
  attr_reader :service, :test_message_body, :test_phone_number

  setup do
    @test_message_body = 'Test message'
    @test_phone_number = '8005551212'

    @service = SendMessageService.new({ phone_number: test_phone_number, message_body: test_message_body})
    refute_nil service
  end

  teardown do

  end

  test "phone object is created" do
    stored_phone = service.instance_variable_get("@phone")
    assert_equal test_phone_number, stored_phone.number
  end

  test "message object is created" do
    stored_message = service.instance_variable_get("@message")
    assert_equal test_message_body, stored_message.message_body
  end

  test "service validates" do
    skip "SKIPPED: code to determine callback is not written yet"
    assert service.validate, "OOPS! the service should validate"
  end
end
