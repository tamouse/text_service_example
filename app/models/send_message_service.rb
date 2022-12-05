# frozen_string_literal: true

class SendMessageService
  include ActiveModel::Model

  attr_accessor :message,
                :phone,
                :provider,
                :endpoint,
                :callback

  delegate :success, :success?, to: :client, allow_nil: true
  delegate :message_guid, to: :message, allow_nil: true
  
  validates :message, presence: true
  validates :phone, presence: true
  validate { errors.add(:phone, :inactive) unless message.phone.status == Phone::STATUS_ACTIVE }
  validate { errors.add(:provider, :unavailable) unless provider.present? }

  validates :endpoint, presence: true
  validates :callback, presence: true

  def initialize(message:)
    super
    @message = message
    @phone = @message&.phone
    @provider = ProviderSelectorService.provider except: message.last_provider
    @endpoint = @provider&.endpoint
    @callback = CallbackDefinitionService.callback
  end

  def send!
    if valid?
      message.update(iteration: message.iteration + 1, last_provider: provider)
      client.post(phone_number: message.phone.number, message_body: message.message_body)
      if success?
        update_message
      else
        copy_errors
      end
    end
    log_activity
    success
  end

  def client
    @client ||= ProviderApi::Client.new(
      endpoint: endpoint,
      callback: callback
    )
  end

  def copy_errors
    errors.add(:client, client.result.parsed_body.dig("error"))
    message.update(status: Message::STATUS_FAILED)
  end


  def log_activity
    message.activity_logs.create do |log|
      log.origin = self.class.name
      log.success = success
      log.is_valid = success
      log.data = {
        message: message.as_json,
        phone: message.phone.as_json,
        provider: provider.as_json,
        callback: callback.as_json,
        client: client.as_json,
        result: client&.result.as_json,
        raw_body: client&.result&.raw_body,
        errors: errors.as_json
      }.to_json
    end

    message.phone.activity_logs.create do |log|
      log.origin = self.class.name
      log.success = success
      log.is_valid = success
      log.data = {
        message: message.as_json,
        phone: message.phone.as_json,
        provider: provider.as_json,
        callback: callback.as_json,
        client: client.as_json,
        result: client&.result.as_json,
        raw_body: client&.result&.raw_body,
        errors: errors.as_json
      }.to_json
    end
  end

  def update_message
    guid = client.result.parsed_body.dig("message_id")
    message.update(
      message_guid: guid,
      status: success? ? Message::STATUS_SENT : Message::STATUS_FAILED
    )
  end
end
