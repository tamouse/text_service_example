# frozen_string_literal: true

class WebookService
  include ActiveModel::Model

  attr_accessor :status,
                :message_id,
                :message,
                :phone

  validates :status, presence: true
  validates :message_id, presence: true
  validates :message, presence: true
  validates :phone, presence: true

  def self.process_webhook(status:, message_id:)
    new(status: status, message_id: message_id)
  end


  def initialize(status:, message_id:)
    @status = status
    @message_id = message_id
    @message = Message.find_by(message_id: message_id)
    @phone = message&.phone
  end

  # @returns [Boolean] success or failure
  def process_webhook
    update_message
    update_phone
    retry_send unless status == Message::STATUS_DELIVERED
  end

  def retry_send
    # Launch a background job to try sending the message again.
    # Do this until the message.iteration hits the max allowed, then fail completely
  end


  def update_message
    return unless valid?

    message.update(status: status)
    message.activity_logs.create do |log|
      log.success = status == Message::STATUS_DELIVERED
      log.is_valid = status == Message::STATUS_DELIVERED
      log.data = {
        status: status,
        message_id: message_id,
        message: message.as_json,
        phone: phone.as_json
      }.to_json
    end
  end

  def update_phone
    return unless valid?

    phone.update(status: status)
    phone.activity_logs.create do |log|
      log.success = status != Phone::STATUS_INVALID
      log.is_valid = status != Phone::STATUS_INVALID
      log.data = {
        status: status,
        message_id: message_id,
        message: message.as_json,
        phone: phone.as_json
      }.to_json
    end
  end

end
