class SendMessageJob < ApplicationJob
  queue_as :default

  def perform(message:)
    Rails.logger.info "Starting #{self.class.name}"
    message.update(status: Message::STATUS_RETRYING)
    SendMessageService.new(message: message).send!
  end
end
