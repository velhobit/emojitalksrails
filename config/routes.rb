Rails.application.routes.draw do
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # PWA service worker and manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Root path
  # root "posts#index"

  # User routes
  resources :users
  post 'signup', to: 'auth#signup'
  post 'login', to: 'auth#login'
  get 'validate_token', to: 'auth#validate_token'

  # Rotas de personalização de usuário
  resources :user_customizations
  
  # Rotas para fóruns
  resources :forums
  
  # Rotas para emojis dos fóruns
  resources :forum_emojis
  
  # Rotas para posts
  resources :posts
  
  # Rotas para comentários
  resources :comments
end