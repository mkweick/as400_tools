Rails.application.routes.draw do
  root 'static_pages#home'
  get '/unlock-po',  to: 'po_tools#unlock_po'
  get '/login',     to: 'sessions#new'
  post '/login',    to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
end
