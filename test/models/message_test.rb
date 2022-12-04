# frozen_string_literal: true

# == Schema Information
#
# Table name: messages
#
#  id           :integer          not null, primary key
#  iteration    :integer          default(0)
#  message_body :text
#  message_guid :string
#  status       :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  phone_id     :integer
#
# Indexes
#
#  index_messages_on_phone_id  (phone_id)
#
require "test_helper"

class MessageTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
