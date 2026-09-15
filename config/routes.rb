Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token

  root to: "categories#index"
  resources :categories, only: [:index, :show]

  namespace :admin do
    resources :categories do
      resources :subcategories do
        resources :photos, only: [:destroy] do
          member do
            patch :move_higher
            patch :move_lower
          end
        end
      end
    end
  end
end
