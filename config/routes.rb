Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token

  root to: "categories#index"
  resources :categories, only: [:index, :show]

  namespace :admin do
    resources :categories do
      resources :subcategories
    end
  end
end
