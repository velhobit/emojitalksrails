Rails.application.routes.draw do
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # PWA service worker and manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Root path
  # root "posts#index"

  # User routes
  get 'users/current', to: 'users#current', as: 'current_user'

  resources :users do
    member do
      post 'follow'
      delete 'unfollow'
      post 'block'
      delete 'unblock'
    end
  end
  
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
  resources :posts, param: :uuid do
    member do
      post :like   # Adiciona a rota para o método like
      delete :unlike  # Adiciona a rota para o método unlike
    end
  end
  
  # Rotas para posts de um forum
  get '/forums/:alias/posts', to: 'forums#posts_by_alias'
  
  # Rotas para comentários
  resources :comments do
    collection do
      get 'post/:post_uuid', to: 'comments#comments_by_post', as: 'by_post'
    end
  end
end