Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token

  root to: "categories#index"
  resources :categories, only: [:index, :show]

  get "about", to: "about#show"

  get "sitemap.xml", to: "sitemap#index", as: :sitemap, defaults: { format: :xml }
  resource :contact, only: [:create]
  get "contact", to: redirect("/about"), as: nil # filet de sécurité si l'utilisateur rafraîchit après une erreur 422

  namespace :admin do
    root to: "dashboard#index"
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
            patch :colspan
          end
        end
      end
    end
  end
end
