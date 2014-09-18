require 'resque/server'

Rails.application.routes.draw do
  resources :panels

  resources :bills, :except => [:show, :new, :edit, :update, :destroy] do
    collection { get 'topics(/:topic)', :to => :topics }
  end

  mount Dashing::Engine, at: Dashing.config.engine_path

  mount Resque::Server.new, at: '/resque'

  root 'welcome#index'
end
