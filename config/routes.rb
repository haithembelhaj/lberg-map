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
    # create proper scoping for unreviewed
    get '/unreviewed' => 'places#index_unreviewed', as: :unreviewed
    scope 'places' do
      post '/:id/revert' => 'versions#revert', as: :revert
      get '/:id/review' => 'places#review', as: :review
      patch '/:id/review' => 'places#update_reviewed'
    end
  end
end
