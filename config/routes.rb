# == Route Map
#

Rails.application.routes.draw do
  post '/delivery_status', to: 'webhook#create', as: 'webhook'
  
  resources :messages, only: [:index, :show]
  resources :phones, only: [:index, :show]
  resources :providers, only: [:index, :show]

  namespace :api do
    namespace :v1 do
      post '/send', to: 'send_message#create', as: 'send'
    end
  end

  root 'phones#index'
end
