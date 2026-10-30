Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token

  root to: "home#index"
  resources :categories, only: [:index, :show] do
    resources :subcategories, only: [:show]
  end

  get "about", to: "about#show"

  get "sitemap.xml", to: "sitemap#index", as: :sitemap, defaults: { format: :xml }
  resource :contact, only: [:create]
  get "contact", to: redirect("/about"), as: nil # filet de sécurité si l'utilisateur rafraîchit après une erreur 422

  namespace :admin do
    root to: "dashboard#index"
    resource :about_page, only: [:edit, :update]

    resources :home_features, only: [:index, :destroy] do
      collection do
        patch :reorder
      end
      member do
        patch :colspan
      end
    end

    resources :categories do
      resource :home_feature, only: [:create, :destroy]
      resources :subcategories do
        resource :home_feature, only: [:create, :destroy]
        resources :photos, only: [:destroy] do
          resource :home_feature, only: [:create, :destroy]
          collection do
            patch :reorder
          end
          member do
            patch :colspan
          end
        end
      end
    end
  end
end
