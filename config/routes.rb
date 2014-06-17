Ritly::Application.routes.draw do
  root "urls#index"
  resources :urls #TODO: restrict this to just :create, :new and :show
  get '/:code', to: 'urls#redirectors'
  get '/:code/preview', to: 'urls#preview'
end
