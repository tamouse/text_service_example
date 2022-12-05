class MessagesController < ApplicationController
  def index
    @messages = Message.order(created_at: :desc)
  end

  def show
    message_id = params[:id]
    @message = Message.find message_id
    @activity_logs = @message.activity_logs
  end
end
