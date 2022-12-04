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

class Message < ApplicationRecord
  STATUS_SENDING   = 'sending'
  STATUS_SENT      = 'sent'
  STATUS_DELIVERED = 'delivered'
  STATUS_FAILED    = 'failed'
  STATUS_RETRYING  = 'retrying'
  STATUS_INVALID   = 'invalid'
  STATUS_ERROR     = 'error'
  
  MAX_TRIES = 3
  
  belongs_to :phone
  has_many :activity_logs, as: :loggable, dependent: :destroy

  before_validation :set_status
  
  validates :message_body, presence: true
  validates :status, presence: true

  def can_retry?
    iteration < MAX_TRIES && status == STATUS_FAILED
  end

  private

  def set_status
    status = STATUS_SENDING unless status.present?;
  end

end
