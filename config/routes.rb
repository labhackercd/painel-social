Rails.application.routes.draw do
  resources :panels

  mount Dashing::Engine, at: Dashing.config.engine_path

  root 'welcome#index'
end
