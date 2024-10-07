Rails.application.routes.draw do
  resources :orders

  resources :customers

  delete "/customers/customerAndOrders/:id", to: "customers#destroy_with_orders"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root to: 'customers#index'
end
