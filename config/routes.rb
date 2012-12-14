Foodrubix::Application.routes.draw do

  ActiveAdmin.routes(self)

  devise_for :admin_users, ActiveAdmin::Devise.config

  resources :likes, :only => [:new, :create, :destroy]

  resources :authentications
  resources :data_points
  resources :users
  resources :user_sessions, :only => [:create, :destroy]
  resources :password_resets
  resources :user_verifications
  resources :friendships
  resources :comments, :except => [:show, :edit, :update]

  match "register" => "users#new", :as => :register
  match 'login' => "user_sessions#new", :as => :login
  match 'logout' => "user_sessions#destroy", :as => :logout
  match 'lost_password' => "password_resets#new", :as => :lost_password
  match 'confirm' => "user_verification#show", :as => :confirm
  match 'upload' => "data_points#new", :as => :upload
  match 'home'  => 'pages#show', :id => 'home', :as => "home", :format => false
  match '/auth/:provider/callback' => 'authentications#create'
  match '/auth/:provider/failure', to: redirect('/login')
  match 'team_rubix' => 'users#index', :as => :team_rubix
  match 'following' => 'friendships#index', :as => :following

  namespace :admin do
    resources :users
    match 'mailer(/:action(/:id(.:format)))' => 'mailer#:action'

  end

  # http://chris.chowie.net/2011/02/17/Username-in-Rails-routes/
  match ":username/edit", :to => "users#edit",
                          :as => "edit_user",
                          :via => :get

  match ":username",:to => "users#show",
                    :as => "user",
                    :via => :get

  match ":username",:to => "users#update",
                    :as => "user",
                    :via => :put

  match ":username",:to => "users#destroy",
                    :as => "user",
                    :via => :delete




  # namespace :users, :as => :user,  :path => '/:username' do
  #     resources :data_points
  # end

  match '/:id' => 'high_voltage/pages#show', :as => :static, :via => :get

  root :to => 'home_redirect#show'



  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end


  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
