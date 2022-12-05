# frozen_string_literal: true

module Api
  module V1
    class SendMessageController < ApiBaseController
      def create
        phone = build_phone(phone_number: message_params[:phone_number])
        if phone.active?
          message = build_message(phone: phone, message_body: message_params[:message_body])
          if message.persisted?
            service = SendMessageService.new(message: message)
            service.send!
            if service.success?
              render status: :ok, json: { message_id: service.message_guid }
            else
              render status: :unprocessable_entity, json: service.errors.details
            end
          else
            render status: :unprocessable_entity, json: message.errors.details
          end
        else
          render status: :unprocessable_entity, json: { error: "Phone is #{phone.status}"}
        end
      end

      private

      def build_message(phone:, message_body:)
        Message.create do |m|
          m.phone = phone
          m.message_body = message_body
          m.status = Message::STATUS_SENDING
        end
      end

      def build_phone(phone_number:)
        Phone.find_or_create_by(number: phone_number)
      end

      def message_params
        params.permit(:phone_number, :message_body)
      end
    end
  end
end
