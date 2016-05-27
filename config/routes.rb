Rails.application.routes.draw do
  post "users" => "users#create"
  get "api" => "api#index"

  root "api#index"

  resources :tours do
    resources :waypoints, only: [:update, :destroy] do
      collection do
        put "reposition"
      end
    end
  end
end
