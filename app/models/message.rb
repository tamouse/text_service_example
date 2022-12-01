class Message < ApplicationRecord
  belongs_to :phone
  has_many :tries, class_name: 'MessageTry', foreign_key: :mewsage_id
end
