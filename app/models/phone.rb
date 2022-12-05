# frozen_string_literal: true

# == Schema Information
#
# Table name: phones
#
#  id         :integer          not null, primary key
#  number     :string
#  status     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Phone < ApplicationRecord
  STATUS_ACTIVE   = 'active'
  STATUS_INACTIVE = 'inactive'
  STATUS_INVALID  = 'invalid'

  before_validation :set_status
  
  has_many :messages, dependent: :nullify
  has_many :activity_logs, as: :loggable, dependent: :destroy

  def active
    status == Phone::STATUS_ACTIVE
  end
  alias_method :active?, :active

  def can_use?
    active
  end

  def inactive
    status == Phone::STATUS_INACTIVE
  end
  alias_method :inactive?, :inactive

  def invalid
    status == Phone::STATUS_INVALID
  end
  alias_method :invalid?, :invalid

  def invalidate!
    update(status: Phone::STATUS_INVALID)
  end

  private

  def set_status
    self.status = Phone::STATUS_ACTIVE unless status.present?
  end
end
