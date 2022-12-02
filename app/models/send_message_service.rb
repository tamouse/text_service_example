# frozen_string_literal: true

class SendMessageService
  include ActiveModel::Model

  attr_accessor :callback,              # The callback to pass to the send request
                :client,                # Provider API client
                :endpoint,              # The Provider API Endpoint to call
                :message_body,          # Body of the text message
                :phone_number,          # Recipient phone number for the message
                :provider,              # The chosen provider
                :success                # Boolean result of the send! operation

  validates :callback, presence: true
  validates :client, presence: true
  validates :endpoint, presence: true
  validates :message_body, presence: true
  validates :phone_number, presence: true
  validate do
    errors.add(:phone_number, 'must be active') unless @phone.status == Phone::STATUS_ACTIVE
  end

  def initialize(message_params)
    @phone_number = message_params[:phone_number]
    @message_body = message_params[:message_params]
    build_phone
    build_message
    choose_provider
    determine_callback
    set_endpoint
  end

  def send!
    if valid!
      client.post(phone_number: phone_number, message_body: message_body)
      @success = client.success?
      if success?
        update_message
      else
        copy_errors
      end
    else
      @success = false
    end
  end

  def build_message
    @message = Message.create do |m|
      m.phone = @phone
      m.message_body = message_body
      m.status = Message::STATUS_SENDING
    end
  end

  def build_phone
    @phone = Phone.find_or_create_by(number: phone_number) do |p|
      p.status = Phone::STATUS_ACTIVE
    end
  end

  def choose_provider
    @provider ||= ProviderSelectorService.provider
  end

  def client
    @client ||= ProviderApi::Client.new(
      endpoint: endpoint,
      callback: callback
    )
  end

  def copy_errors
    errors.add(:base, client.result.parsed_body.dig("error"))
  end

  def determine_callback
    @callback ||= CallbackDefinitionService.callback
  end

  def set_endpoint
    @endpoint ||= provider.endpoint
  end

  def success?
    !!success
  end

  def update_message
    guid = client.result.parsed_body.dig("message_id")
    @message.update(
      message_guid: guid,
      status: success? ? Message::STATUS_SENT : Message::STATUS_ERROR      
    )
    @message.activity_logs.create do |l|
      l.success = success
      l.is_valid = success
      l.iteration = l.iteration + 1
      l.blob = client.result.raw_body
    end
  end
end
