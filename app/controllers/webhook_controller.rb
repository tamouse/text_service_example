class WebhookController < ApplicationController

  protect_from_forgery with: :null_session
  
  def create
    if WebhookService.process_webhook(**message_params)
      head :ok
    else
      head :unprocessable_entity
    end
  end

  private

  def message_params
    params.require(:status)
    params.require(:message_id)
    {
      status: params[:status],
      message_guid: params[:message_id]
    }
  end

end
