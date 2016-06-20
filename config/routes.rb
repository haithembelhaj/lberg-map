Rails.application.routes.draw do
  scope '(:locale)', locale: /en|de|fr|ar/ do
    root 'static_pages#map'
    get '/:locale' => 'static_pages#map'
    get '/about' => 'static_pages#about'
    get '/category/:category' => 'places#index', as: :category
    get '/login' => 'sessions#new'
    post '/login' => 'sessions#create'
    get '/logout' => 'sessions#destroy'
    resources :places do
      resources :descriptions
    end
    resources :users
    get '/review' => 'places#review'
  end
end
