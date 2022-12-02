class Phone < ApplicationRecord
  STATUS_ACTIVE = 'active'
  STATUS_INACTIVE = 'inactive'
  
  has_many :activity_logs, as: :loggable, dependent: :destroy
end
