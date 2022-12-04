# frozen_string_literal: true

class SendMessageService
  include ActiveModel::Model

  attr_accessor :message

  delegate :success, :success?, to: :client, allow_nil: true
  delegate :message_guid, to: :message, allow_nil: true
  
  validate do
    errors.add(:phone_number, 'must be active') unless message.phone.status == Phone::STATUS_ACTIVE
  end

  def initialize(message:)
    @message = message
  end

  def send!
    if valid?
      message.update_column(:iteration, message.iteration + 1)
      client.post(phone_number: message.phone.number, message_body: message.message_body)
      if success?
        update_message
      else
        copy_errors
      end
    end
  end

  def provider
    @provider ||= ProviderSelectorService.provider
  end

  def client
    @client ||= ProviderApi::Client.new(
      endpoint: endpoint,
      callback: callback
    )
  end

  def copy_errors
    errors.add(:client, client.result.parsed_body.dig("error"))
  end

  def callback
    @callback ||= CallbackDefinitionService.callback
  end

  def endpoint
    @endpoint ||= provider.endpoint
  end

  def update_message
    guid = client.result.parsed_body.dig("message_id")
    message.update(
      message_guid: guid,
      status: success? ? Message::STATUS_SENT : Message::STATUS_ERROR
    )
    message.activity_logs.create do |l|
      l.origin = self.class.name
      l.success = success
      l.is_valid = success
      l.data = client.result.raw_body
    end
  end
end
