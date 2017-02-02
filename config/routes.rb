Rails.application.routes.draw do
  root 'messages#new'

  devise_for :users, :controllers => {:registrations => "users/registrations", :sessions => "users/sessions", :passwords => "users/passwords", :confirmations => "users/confirmations"}

  get 'message' => 'messages#new', as: :message
  post 'message/send' => 'messages#send_message', as: :send_message
  get 'message/send' => 'messages#new'
  get '/ad7e2b2a24677ed2eecf953edf1abfa1/b19e8e47-19f5-4162-8447-e56cb5ef8a34/api/message/:sender/:msisdn/:message' => 'messages#filter_api_send_message'
  get '/ad7e2b2a24677ed2eecf953edf1abfa1/b19e8e47-19f5-4162-8447-e56cb5ef8a34/api/message/:login/:password/:service_id/:sender/:msisdn/:message' => 'messages#filter_api_send_message'
  get '/ad7e2b2a24677ed2eecf953edf1abfa1/b19e8e47-19f5-4162-8447-e56cb5ef8a34/api/message/:msisdn/:message' => 'messages#api_send_message'

  get 'transactions' => 'transactions#list', as: :transactions

  get 'message_logs/:transaction_id' => 'message_logs#list', as: :message_logs

  get 'search' => 'search#index', as: :search
  post 'search/perform' => 'search#perform', as: :perform_search
  get 'search/perform' => 'search#index'

  get "request_log" => "custom_logs#logs"
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
  get '*rogue_url', :to => 'errors#routing'
  post '*rogue_url', :to => 'errors#routing'
end
