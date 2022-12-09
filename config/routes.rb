Rails.application.routes.draw do
  namespace :carts do
    resource :add, only: :create
    resource :reduce, only: :create
    resource :remove, only: :destroy
  end
  resource :checkout, only: :show
  post :search, to: "searches#show"
  resources :products
  resources :categories
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  
  root to: 'welcome#index'
end
