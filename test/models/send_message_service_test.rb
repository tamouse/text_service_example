# frozen_string_literal: true

class SendMessageServiceTest < ActiveSupport::TestCase
  test "service validates" do
    msg = messages(:message_1)
    service = SendMessageService.new(message: msg)
    assert_predicate service, :valid?
  end

  test "using an invalid phone" do
    msg = messages(:message_1)
    phone = msg.phone
    phone.update(status: Phone::STATUS_INVALID)
    service = SendMessageService.new(message: msg)
    refute_predicate service, :valid?
  end
end
