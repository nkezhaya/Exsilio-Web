Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "registrations", sessions: "sessions" }
  get "api" => "api#index"
  get "users/me" => "users#me"

  root "api#index"

  resources :tours do
    get "search", on: :collection
    get "start", on: :member

    resources :waypoints, only: [:create, :update, :destroy] do
      put "reposition", on: :collection
    end
  end
end
