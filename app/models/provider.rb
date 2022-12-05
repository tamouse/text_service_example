# frozen_string_literal: true

# == Schema Information
#
# Table name: providers
#
#  id         :integer          not null, primary key
#  endpoint   :string
#  weight     :decimal(, )
#  status     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Provider < ApplicationRecord

  STATUS_ACTIVE   = "active"
  STATUS_INACTIVE = "inactive"
  
  has_many :activity_logs, as: :loggable, dependent: :destroy

  scope :active, ->{ where(status: Provider::STATUS_ACTIVE) }

  def active
    status == Phone::STATUS_ACTIVE
  end
  alias_method :active?, :active

  def inactive
    status == Phone::STATUS_INACTIVE
  end
  alias_method :inactive?, :inactive

  def deactivate!
    self.status = STATUS_INACTIVE
    save
  end
end
