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
  validate :ensure_phone_is_active
 
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
    if valid?
      update_message
      update_phone
      retry_send_on_failure
      true
    else
      log_activity
      false
    end
  end

  private

  def ensure_phone_is_active
    return unless phone.present?

    errors.add(:phone, :invalid) if phone.invalid?
  end


  def log_activity
    # There's not a model for web hooks, but maybe there should be to just log activity to. Think about it
    ActivityLog.create do |log|
      log.origin = self.class.name
      log.success = false
      log.is_valid = false
      log.loggable_type = self.class.name
      log.data = {
        reason: :invaoild_webhook_service,
        errors: errors.details.as_json,
        status: status.as_json,
        message_guid: message_guid.as_json,
        message: message.as_json,
        phone: phone.as_json
      }.to_json
    end
  end


  def retry_send_on_failure
    return if status == Message::STATUS_FAILED
    return if message.iteration > Message::MAX_TRIES

    SendMessageJob.set(wait: message.iteration.seconds).perform_later(message: message)
  end


  def update_message
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
