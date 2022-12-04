module ApplicationHelper

  def earliest_message
    Message.order(created_at: :asc).first.created_at
  end
  def latest_message
    Message.order(created_at: :desc).first.created_at
  end

end
