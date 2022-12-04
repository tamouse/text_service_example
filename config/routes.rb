# == Route Map
#

Rails.application.routes.draw do
  post '/delivery_status', to: 'webhook#create', as: 'webhook'
  
  resources :messages, only: [:index]
  resources :phones, only: [:index]
  resources :providers, only: [:index]

  namespace :api do
    namespace :v1 do
      post '/send', to: 'send_message#create', as: 'send'
    end
  end

  root 'phones#index'
end
