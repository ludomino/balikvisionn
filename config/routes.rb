Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token

  root to: "categories#index"
  resources :categories, only: [:index, :show]

  get "about", to: "about#show"

  resource :contact, only: [:create]

  namespace :admin do
    resource :about_page, only: [:edit, :update]
    resources :categories do
      resources :subcategories do
        resources :photos, only: [:destroy] do
          collection do
            patch :reorder
          end
          member do
            patch :move_higher
            patch :move_lower
          end
        end
      end
    end
  end
end
