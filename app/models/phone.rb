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
  
  has_many :messages, dependent: :nullify
  has_many :activity_logs, as: :loggable, dependent: :destroy

  def active
    status == STATUS_ACTIVE
  end
  alias_method :active?, :active

  def can_use?
    active
  end

  def invalid
    status == STATUS_INVALID
  end
  alias_method :invalid?, :invalid

end
