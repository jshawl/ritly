Ritly::Application.routes.draw do
  devise_for :users
  root "urls#index"
  resources :urls #TODO: restrict this to just :create, :new and :show
  get '/:code', to: 'urls#redirectors'
  get '/:code/p', to: 'urls#preview'
end
