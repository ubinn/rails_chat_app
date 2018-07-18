Rails.application.routes.draw do
  root 'rooms#index'
  resources :rooms do
    member do 
      delete '/exit' => 'rooms#user_exit_room'
      post '/ready' => 'rooms#is_user_ready'
      post '/open_chat' => 'rooms#open_chat'
      get '/chat' => 'rooms#chat'
      post '/chat' => 'rooms#chat'
    end
  end
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
