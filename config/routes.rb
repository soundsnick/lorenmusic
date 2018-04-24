Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'tracks#index'

  get '/search', to: 'tracks#search', as: :search_view
  get '/tracks/:id(.:format)', to: 'tracks#getTrack', as: :track_view
  get '/track/add', to: 'tracks#addView', as: :track_new_view
  post '/track/add', to: 'tracks#add', as: :add_action
  get '/playlist', to: 'tracks#playlist', as: :my_playlist
  get '/author/:id(.:format)/tracks', to: 'tracks#userTracks', as: :my_tracks

  get '/login', to: 'users#signin', as: :login_view
  post '/login', to: 'users#login', as: :login_action
  get '/register', to: 'users#signup', as: :register_view
  post '/register', to: 'users#register', as: :register_action
  get '/logout', to: 'users#logout', as: :logout

  get '/api', to: 'api#index'
  get '/api/tracks.all', to: 'api#tracks_all'
  get '/api/tracks.find', to: 'api#tracks_find'
  get '/api/playlist.change', to: 'api#playlist_change'
  get '/api/playlist.check', to: 'api#playlist_check'
  get '/api/user.all', to: 'api#user_all'
  get '/api/user.search', to: 'api#user_search'
  get '/api/user.auth', to: 'api#user_auth'

end
