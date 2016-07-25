Rails.application.routes.draw do
  root 'static_pages#home'

  get '/unlock-po',                 to: 'po_tools#unlock_po'
  get '/unlock-whs-item',           to: 'item_tools#unlock_whs_item'
  get '/unlock-vendor',             to: 'vendor_tools#unlock_vendor'
  get '/unlock-voucher-group-id',   to: 'accounting_tools#unlock_voucher_group_id'

  get '/login',                     to: 'sessions#new'
  post '/login',                    to: 'sessions#create'
  delete '/logout',                 to: 'sessions#destroy'
end
