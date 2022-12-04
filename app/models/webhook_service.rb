# frozen_string_literal: true

class WebhookService
  include ActiveModel::Model

  attr_accessor :status,
                :message_guid,
                :message,
                :phone

  validates :status, presence: true
  validates :message_guid, presence: true
  validates :message, presence: true
  validates :phone, presence: true

  def self.process_webhook(status:, message_guid:)
    new(status: status, message_guid: message_guid).process_webhook
  end

  def initialize(status:, message_guid:)
    @status = status
    @message_guid = message_guid
    @message = Message.find_by(message_guid: message_guid)
    @phone = message&.phone
  end

  # @returns [Boolean] success or failure
  def process_webhook
    update_message
    update_phone
    retry_send if status == Message::STATUS_FAILED
    true
  rescue
    false
  end

  def retry_send
    # Launch a background job to try sending the message again.
    # Do this until the message.iteration hits the max allowed, then fail completely
  end


  def update_message
    return unless valid?

    message.update(status: status)
    message.activity_logs.create do |log|
      log.origin = self.class.name
      log.success = status == Message::STATUS_DELIVERED
      log.is_valid = status == Message::STATUS_DELIVERED
      log.data = {
        status: status,
        message: message.as_json,
        phone: phone.as_json
      }.to_json
    end
  end

  def update_phone
    return unless valid?

    phone.update(status: status)
    phone.activity_logs.create do |log|
      log.origin = self.class.name
      log.success = status != Phone::STATUS_INVALID
      log.is_valid = status != Phone::STATUS_INVALID
      log.data = {
        status: status,
        message: message.as_json,
        phone: phone.as_json
      }.to_json
    end
  end

end
