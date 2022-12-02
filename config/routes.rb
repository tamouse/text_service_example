Rails.application.routes.draw do
  post '/delivery_status', to: 'webhook#create', as: 'webhook'
  get 'phones/index'
  root 'phones#index'
end
