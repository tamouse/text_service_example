class ProvidersController < ApplicationController
  def index
    @providers = Provider.order(created_at: :desc)
  end
end
