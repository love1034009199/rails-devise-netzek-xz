Rails.application.routes.draw do
  resources :discount_fees

  resources :primary_fees

  resources :posts

  root to: 'visitors#index'
  devise_for :users
  resources :users
end
