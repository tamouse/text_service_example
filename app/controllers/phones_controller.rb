class PhonesController < ApplicationController
  def index
    @phones = Phone.order(created_at: :desc)
  end

  def show
    @phone = Phone.find(params[:id])
    @activity_logs = @phone.activity_logs
  end
end
