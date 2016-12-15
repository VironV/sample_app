Rails.application.routes.draw do
  resources :users
  resources :films
  resources :sessions, only: [:new, :create, :destroy]
  resources :ratings
  resources :preferences

  root  'static_pages#home'
  match '/signup',          to: 'users#new',                via: 'get'
  match '/signin',          to: 'sessions#new',             via: 'get'
  match '/signout',         to: 'sessions#destroy',         via: 'delete'
  match '/help',            to: 'static_pages#help',        via: 'get'
  match '/films',           to: 'static_pages#films_list',  via: 'get'
  match '/films_list',      to: 'static_pages#films_list',  via: 'get'
  match '/about',           to: 'static_pages#about',       via: 'get'
  match '/contact',         to: 'static_pages#contact',     via: 'get'
  match '/recommend',       to: 'recommender_system#show_choice',  via: 'get', as:'recommender_choice'
  match '/recommend/result', to: 'recommender_system#show_results', via: 'get', as: 'show_calculations_results'
  match '/recommend/show_films', to: 'recommender_system#show_recommended_films', via: 'get', as: 'recommended_films'
  match '/recommend/calculate_result', to: 'recommender_system#calculate_and_show_results', via: 'get', as: 'calculate_and_show_results'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
