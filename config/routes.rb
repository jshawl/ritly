Ritly::Application.routes.draw do
  devise_for :users
  root "urls#index"
  resources :urls #TODO: restrict this to just :create, :new and :show
  get '/callback', to: 'urls#auth_finish'
  get '/:code', to: 'urls#preview'
  match 'upload', to: 'urls#upload', via: :post
end
