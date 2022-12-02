# frozen_string_literal: true

module Api
  module V1
    class SendMessagesController < ApiBaseController
      def create
        service = SendMessageService.new(message_params)
        service.send!
        if service.success?
          render status: :ok, json: service.messages
        else
          render status: :unprocessible_entity, json: service.errors.detail
        end
      end

      private

      def message_params
        {
          message_body: permit(:message_body),
          phone_number: permit(:phone_number)
        }
      end
    end
  end
end
