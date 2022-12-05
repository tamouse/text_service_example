# frozen_string_literal: true

# == Schema Information
#
# Table name: messages
#
#  id               :integer          not null, primary key
#  iteration        :integer          default(0)
#  message_body     :text
#  message_guid     :string
#  status           :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  last_provider_id :integer
#  phone_id         :integer
#
# Indexes
#
#  index_messages_on_last_provider_id  (last_provider_id)
#  index_messages_on_phone_id          (phone_id)
#

class Message < ApplicationRecord
  STATUS_SENDING   = 'sending'          # Message is brand new, has not been sent yet (Initial state)
  STATUS_SENT      = 'sent'             # Has been sent
  STATUS_DELIVERED = 'delivered'        # Message was delivered
  STATUS_FAILED    = 'failed'           # Message delivery failed for some reason, can be retried
  STATUS_RETRYING  = 'retrying'         # We're retrying the send
  STATUS_ERROR     = 'error'            # Can't send due to some error, such as no providers
  STATUS_DEAD      = 'dead'             # Can't send because the limit was reached
  
  MAX_TRIES = 3
  
  belongs_to :phone
  belongs_to :last_provider, class_name: 'Provider', optional: true
  has_many :activity_logs, as: :loggable, dependent: :destroy
  

  before_validation :set_status
  before_validation :check_for_dead
  
  validates :message_body, presence: true
  validates :status, presence: true
  
  def delivered
    status == STATUS_DELIVERED
  end
  alias_method :delivered?, :delivered

  def dead
    status == STATUS_DEAD
  end
  alias_method :dead?, :dead

  def error
    status == STATUS_ERROR
  end
  alias_method :error?, :error

  def failed
    status == STATUS_FAILED
  end
  alias_method :failed?, :failed

  def kill!
    self.status = STATUS_DEAD
    save!
  end

  def retrying
    status == STATUS_RETRYING
  end
  alias_method :retrying?, :retrying

  def sending
    status == STATUS_SENDING
  end
  alias_method :sending?, :sending

  def sent
    status == STATUS_SENT
  end
  alias_method :sent?, :sent


  def can_retry?
    iteration <= MAX_TRIES && [STATUS_SENT, STATUS_FAILED].include?(status)
  end

  private

  def check_for_dead
    status = STATUS_DEAD if iteration > MAX_TRIES
  end

  def set_status
    status = STATUS_SENDING unless status.present?
  end
end
