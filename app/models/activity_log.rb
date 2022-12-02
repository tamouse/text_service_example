class ActivityLog < ApplicationRecord
  belongs_to :loggable, polymorphic: true
end
