Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'static_pages#map'

  post '/reverse_geocoding' => 'static_pages#reverse_geocoding'
  get '/about' => 'static_pages#about'

  resources :places do
    resources :descriptions
  end
end
