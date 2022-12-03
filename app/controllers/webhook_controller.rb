class WebhookController < ApplicationController
  def create
    if WebhookService.update_message(**message_params)
      head :ok
    else
      head :error
    end
  end

  private

  def message_params
    params.permit(:status, :message_id)
  end

end
