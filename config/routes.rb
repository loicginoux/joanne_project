Foodrubix::Application.routes.draw do

  devise_for :admin_users, ActiveAdmin::Devise.config

# utility for flushing cache
  match 'data_points/fileInputForm/(:id)',
    :to => "data_points#getFileUploadForm",
    :via => :get,
    :as => "fileUploadForm"
  resources :authentications, :only => [:create]
  resources :data_points
  resources :week_data_points
  resources :day_data_points
  resources :month_data_points

  resources :users do
    get :follow, :on => :member
  end
  resources :preferences, :only => [:edit, :update]
  resources :user_sessions, :only => [:create, :destroy]
  resources :password_resets
  resources :user_verifications
  resources :friendships, :only => [:index, :create, :destroy]
  resources :comments, :except => [:show, :edit]
  resources :likes, :only => [:new, :create, :destroy]

  match "register" => "users#new",:via => :get, :as => :register
  match "register" => "users#create",:via => :post, :as => :register
  match "register" => "users#create",:via => :put

  match 'login' => "user_sessions#new", :as => :login, :via => :get
  match 'login' => "user_sessions#create", :via => :post, :as => :login
  match 'login' => "user_sessions#create", :via => :put

  match 'logout' => "user_sessions#destroy", :as => :logout
  match 'lost_password' => "password_resets#new", :as => :lost_password
  match 'confirm' => "user_verification#show", :as => :confirm
  match 'upload' => "data_points#new", :as => :upload
  match 'home'  => 'pages#show', :id => 'home', :as => "home", :format => false
  match 'terms_of_services'  => 'pages#show', :id => 'terms_of_services', :as => "terms_of_services", :format => false
  match 'privacy'  => 'pages#show', :id => 'privacy', :as => "privacy", :format => false
  # match 'fileInputForm'  => 'pages#show', :id => 'fileInputForm', :as => "fileInputForm", :format => false

  match '/auth/:provider/callback' => 'authentications#create'
  match '/auth/:provider/failure', to: redirect('/login')
  match '/favicon.ico', to: redirect('/assets/favicon.ico')
  match 'team_rubix' => 'users#index', :as => :team_rubix
  match 'feed' => 'friendships#index', :as => :feed

  namespace :admin do
    match 'mailer(/:action(/:id(.:format)))' => 'mailer#:action'
    match 'mailer/index' => 'mailer#index'

  end

  ActiveAdmin.routes(self)

  # http://chris.chowie.net/2011/02/17/Username-in-Rails-routes/
  match ":username/edit", :to => "users#edit",
                          :as => "edit_user",
                          :via => :get

  match ":username/follow", :to => "users#follow",
                          :as => "follow_user",
                          :via => :get

  match ":username/edit", :to => "users#update",
                          :via => :put

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
