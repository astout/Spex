Spex::Application.routes.draw do
  post "hub/create_entity"
  post "hub/entitys_groups"
  post "hub/groups_properties"
  post "hub/delete_entity"
  post "hub/entity_add_groups"
  post "hub/group_add_properties"
  post "hub/create_group"
  post "hub/delete_groups"
  post "hub/delete_properties"
  post "hub/create_property"
  post "hub/delete_entity_group_relations"
  post "hub/top_entity_group_relations"
  post "hub/bottom_entity_group_relations"
  post "hub/up_entity_group_relations"
  post "hub/down_entity_group_relations"
  get "groups/new"
  get "entities/new"
  get "properties/new"
  resources :users
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
  root 'static_pages#home'
  # match '/hub/create_entity', to: 'hub#main',   via: 'get'
  # match '/hub/create_group',  to: 'hub#main',    via: 'get'
  # match '/hub/delete_entity', to: 'hub#main',   via: 'get'
  # match '/hub/delete_groups',  to: 'hub#main',    via: 'get'
  # match '/hub/entity_add_groups', to: 'hub#main',    via: 'get'
  # match '/hub/delete_entity_group_relations', to: 'hub#main',    via: 'get'
  # match '/hub/top_entity_group_relations', to: 'hub#main',    via: 'get'
  # match '/hub/up_entity_group_relations', to: 'hub#main',    via: 'get'
  # match '/hub/down_entity_group_relations', to: 'hub#main',    via: 'get'
  # match '/hub/entitys_groups', to: 'hub#main',  via: 'get'
  match '/signup',  to: 'users#new',            via: 'get'
  match '/hub',     to: 'hub#main',             via: 'get'
  match '/signin',  to: 'sessions#new',         via: 'get'
  match '/signout', to: 'sessions#destroy',     via: 'delete'
  match '/help',    to: 'static_pages#help',    via: 'get'
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
