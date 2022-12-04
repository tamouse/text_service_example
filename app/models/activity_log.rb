# frozen_string_literal: true

# == Schema Information
#
# Table name: activity_logs
#
#  id            :integer          not null, primary key
#  data          :binary
#  is_valid      :boolean
#  loggable_type :string           not null
#  origin        :string
#  success       :boolean
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  loggable_id   :integer          not null
#
# Indexes
#
#  index_activity_logs_on_loggable  (loggable_type,loggable_id)
#

class ActivityLog < ApplicationRecord
  belongs_to :loggable, polymorphic: true
end
