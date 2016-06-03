Rails.application.routes.draw do
  post "users" => "users#create"
  get "api" => "api#index"

  root "api#index"

  resources :tours do
    get "search", on: :collection

    resources :waypoints, only: [:update, :destroy] do
      put "reposition", on: :collection
    end
  end
end
