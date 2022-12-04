class Phone < ApplicationRecord
  STATUS_ACTIVE   = 'active'
  STATUS_INACTIVE = 'inactive'
  STATUS_INVALID  = 'invalid'
  
  has_many :messages, dependent: :nullify
  has_many :activity_logs, as: :loggable, dependent: :destroy

  def active
    status == STATUS_ACTIVE
  end
  alias_method :active?, :active

end
