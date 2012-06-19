Rails.application.routes.draw do
  match 'digital_assets/search' => 'digital_assets#search'
  post "digital_assets/sync" => 'digital_assets#sync_assets'
  # match 'digital_assets/:id' => 'digital_assets#sami'  #, :id => /\w{4,8}.\d*/
  resources :digital_assets, :only => [:index, :show]
  #resources :digital_assets
  #get 'digital_assets' => 'digital_asset#index'
end
