class Phone < ApplicationRecord
  has_many :activity_logs, as: :loggable, dependent: :destroy
end
