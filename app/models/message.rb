class Message < ApplicationRecord
  belongs_to :phone
  has_many :activity_logs, as: :loggable, dependent: :destroy
end
