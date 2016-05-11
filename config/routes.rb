Rails.application.routes.draw do
  post "users" => "users#create"
  get "api" => "api#index"

  root "api#index"

  resources :tours
end
