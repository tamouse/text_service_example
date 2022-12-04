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
    expected = { phone: [ { error: :inactive } ] }
    assert_equal(expected, service.errors.details)
  end

  test "take all providers out of service" do
    Provider.update_all(status: Provider::STATUS_INACTIVE)
    msg = messages(:message_1)
    service = SendMessageService.new message: msg
    refute_predicate service, :valid?
    # NOTE: since endpoint depends on the provider, endpoint will be blank when there's no provider 
    expected = { provider: [ { error: :unavailable } ], endpoint: [ { error: :blank } ] }
    assert_equal(expected, service.errors.details)
  end

end
