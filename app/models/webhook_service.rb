# frozen_string_literal: true

class WebhookService
  include ActiveModel::Model

  WAIT_MULTIPLIER = 2

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
    return if message.sending?
    return if message.iteration.zero?
    
    errors.add(:message, 'has exceeded the retry limit or is not in a retriable state') unless message.can_retry?
  end

  
  def ensure_phone_is_active
    return unless phone.present?

    errors.add(:phone, :invalid) if phone.invalid?
    message.update(status: Message::STATUS_DEAD) if phone.invalid?
  end


  def log_activity
    # There's not a model for web hooks, but maybe there should be to just log activity to. Think about it
    ActivityLog.create do |log|
      log.origin = self.class.name
      log.success = false
      log.is_valid = false
      log.loggable_type = self.class.name
      log.data = {
        reason: :invalid_webhook_service,
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
    return unless message.can_retry?

    SendMessageJob.set(wait: (message.iteration * WAIT_MULTIPLIER).seconds).perform_later(message: message)
  end


  def update_message
    if status == Phone::STATUS_INVALID
      message.kill!
    else
      message.update(status: status)
    end
    message.activity_logs.create do |log|
      log.origin = self.class.name
      log.success = message.delivered?
      log.is_valid = message.delivered?
      log.data = {
        status: status,
        message: message.as_json,
        phone: phone.as_json
      }.to_json
    end
  end

  def update_phone
    phone.invalidate! if status == Phone::STATUS_INVALID
    phone.activity_logs.create do |log|
      log.origin = self.class.name
      log.success = !phone.invalid?
      log.is_valid = !phone.invalid?
      log.data = {
        status: status,
        message: message.as_json,
        phone: phone.as_json
      }.to_json
    end
  end

end
