require 'resque/server'

Rails.application.routes.draw do
  resources :panels

  mount Dashing::Engine, at: Dashing.config.engine_path

  mount Resque::Server.new, at: '/resque'

  root 'welcome#index'
end
