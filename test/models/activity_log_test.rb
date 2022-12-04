# frozen_string_literal: true

# == Schema Information
#
# Table name: activity_logs
#
#  id            :integer          not null, primary key
#  data          :binary
#  is_valid      :boolean
#  loggable_type :string           not null
#  origin        :string
#  success       :boolean
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  loggable_id   :integer          not null
#
# Indexes
#
#  index_activity_logs_on_loggable  (loggable_type,loggable_id)
#
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
