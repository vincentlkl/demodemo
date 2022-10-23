Rails.application.routes.draw do
  resources :posts, only: [:index, :show]
  root to: 'pages#home'
end
