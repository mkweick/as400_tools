Rails.application.routes.draw do
  root 'static_pages#home'
  
  get '/login',                     to: 'sessions#new'
  post '/login',                    to: 'sessions#create'
  delete '/logout',                 to: 'sessions#destroy'

  get '/unlock-po',                 to: 'po_tools#po'
  get '/unlock-whs-item',           to: 'item_tools#whs_item'
  get '/unlock-vendor',             to: 'vendor_tools#vendor'
  get '/unlock-voucher-group-id',   to: 'accounting_tools#voucher_group_id'

  post '/unlock-po',                to: 'po_tools#unlock_po'
  post '/unlock-whs-item',          to: 'item_tools#unlock_whs_item'
  post '/unlock-vendor',            to: 'vendor_tools#unlock_vendor'
  post '/unlock-voucher-group-id',  to: 'accounting_tools#unlock_voucher_group_id'
end
