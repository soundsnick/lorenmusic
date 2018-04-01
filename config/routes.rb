Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'tracks#index'

  get '/login', to: 'users#signin', as: :login_view
  post '/login', to: 'users#login', as: :login_action
  get '/register', to: 'users#signup', as: :register_view
  post '/register', to: 'users#register', as: :register_action
  get '/logout', to: 'users#logout', as: :logout
end
