class Message < ApplicationRecord
  STATUS_SENDING = 'sending'
  STATUS_SENT = 'sent'
  STATUS_ERROR = 'error'
  
  belongs_to :phone
  has_many :activity_logs, as: :loggable, dependent: :destroy
end
