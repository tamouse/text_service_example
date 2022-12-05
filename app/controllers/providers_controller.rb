class ProvidersController < ApplicationController
  def index
    @providers = Provider.order(created_at: :desc)
  end

  def show
    @provider = Provider.find(params[:id])
    @activity_log = @provider.activity_logs
  end
end
