# frozen_string_literal: true

module Api
  module V1
    class SendMessageController < ApiBaseController
      def create
        service = SendMessageService.new(message_params)
        service.send!
        if service.success?
          render status: :ok, json: { message_id: service.message_guid }
        else
          render status: :unprocessable_entity, json: service.errors.details
        end
      end

      private

      def message_params
        {
          message_body: params.permit(:message_body)[:message_body].to_s,
          phone_number: params.permit(:phone_number)[:phone_number].to_s
        }
      end
    end
  end
end
