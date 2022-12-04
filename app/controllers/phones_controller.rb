class PhonesController < ApplicationController
  def index
    @phones = Phone.order(created_at: :desc)
  end
end
