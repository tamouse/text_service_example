# frozen_string_literal: true

class WebhookService
  include ActiveModel::Model

  attr_accessor :status,
                :message_guid,
                :message,
                :options,
                :phone

  validates :status, presence: true
  validates :message_guid, presence: true
  validates :message, presence: true
  validates :phone, presence: true

  validate :ensure_message_can_be_retried
  validate :ensure_phone_is_active
 
  def self.process_webhook(status:, message_guid:, options: {})
    new(status: status, message_guid: message_guid, options: {}).process_webhook
  end

  def initialize(status:, message_guid:, options: {})
    super
    @options = options
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

  def ensure_message_can_be_retried
    return unless message.present?
    return if message.status == Message::STATUS_SENT
    return if message.iteration.zero?
    
    errors.add(:message, 'has exceeded the retry limit or is not in a retriable state') unless message.can_retry?
  end

  
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
    return if options[:no_retry]
    return if status != Message::STATUS_FAILED
    return unless message.can_retry?

    SendMessageJob.set(wait: message.iteration.seconds * 10).perform_later(message: message)
  end


  def update_message
    message.update(status: status) if status != Message::STATUS_INVALID
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
    phone.update(status: status) if status == Phone::STATUS_INVALID
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
