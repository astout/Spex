Spex::Application.routes.draw do
  get "roles/new"
  get "roles/show"
  get "roles/edit"
  post "users/delete_request"
  post "users/confirm_delete"
  post "properties/confirm_delete"
  post "groups/confirm_delete"
  post "entities/confirm_delete"
  post "roles/confirm_delete"
  post "roles/delete_request"
  post "hub/create_entity"
  post "hub/egrs"
  post "hub/gprs"
  post "hub/delete_entity"
  post "hub/delete_egrs"
  post "hub/create_gprs"
  post "hub/create_group"
  post "hub/delete_groups"
  post "hub/delete_properties"
  post "hub/create_property"
  get "hub/property_ref_update"
  post "hub/create_egrs"
  post "hub/delete_gprs"
  # post "hub/top_egrs"
  # post "hub/bottom_egrs"
  # post "hub/up_egrs"
  # post "hub/down_egrs"
  post "hub/move_egrs"
  post "hub/update_epr"
  post "hub/move_eprs"
  # post "hub/top_eprs"
  # post "hub/up_eprs"
  # post "hub/down_eprs"
  # post "hub/bottom_eprs"
  post "hub/top_gprs"
  post "hub/up_gprs"
  post "hub/down_gprs"
  post "hub/bottom_gprs"
  post "hub/eprs"
  post "entities/show"
  get "groups/new"
  get "hub/epr_ref_update"
  get "hub/epr_evaluate"
  get "entities/new"
  get "entities/print"
  post "entities/print_request"
  post "properties/confirm_delete"
  post "properties/delete_request"
  post "entities/confirm_delete"
  post "entities/delete_request"
  post "groups/confirm_delete"
  post "groups/delete_request"
  get "properties/new"
  get "hub/selectize"
  resources :users
  resources :roles
  resources :group_property_relationships
  resources :entity_group_relationships
  resources :entity_property_relationships
  resources :properties do
    member do
      get :groups, :entities
      post :serve
    end  
  end
  resources :groups do
    member do
      get :properties, :entities
      post :own
    end  
  end
  resources :entities do
    member do
      get :groups, :properties
      post :own
    end  
  end

  resources :sessions, only: [:new, :create, :destroy]
  root 'entity_property_relationships#query'
  # match '/hub/create_entity', to: 'hub#main',   via: 'get'
  # match '/hub/create_group',  to: 'hub#main',    via: 'get'
  # match '/hub/delete_entity', to: 'hub#main',   via: 'get'
  # match '/hub/delete_groups',  to: 'hub#main',    via: 'get'
  # match '/hub/delete_egrs', to: 'hub#main',    via: 'get'
  # match '/hub/delete_egrs', to: 'hub#main',    via: 'get'
  # match '/hub/top_egrs', to: 'hub#main',    via: 'get'
  # match '/hub/up_egrs', to: 'hub#main',    via: 'get'
  # match '/hub/down_egrs', to: 'hub#main',    via: 'get'
  # match '/hub/egrs', to: 'hub#main',  via: 'get'
  match '/signup',  to: 'users#new',            via: 'get'
  match '/hub',     to: 'hub#main',             via: 'get'
  match '/signin',  to: 'sessions#new',         via: 'get'
  match '/signout', to: 'sessions#destroy',     via: 'delete'
  match '/help',    to: 'static_pages#help',    via: 'get'
  match '/home',    to: 'static_pages#home',    via: 'get'
  match '/query',   to: 'entity_property_relationships#query',    via: 'get'
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
