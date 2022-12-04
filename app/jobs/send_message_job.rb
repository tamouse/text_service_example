class SendMessageJob < ApplicationJob
  queue_as :default

  def perform(message:)
    message.update(status: Message::STATUS_RETRYING)
    SendMessageService.new(message: message).send!
  end
end
