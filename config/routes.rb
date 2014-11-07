require 'resque/server'

Rails.application.routes.draw do
  resources :panels

  resources :bills, :except => [:show, :new, :edit, :update, :destroy] do
    collection do
      get 'topics(/:topic)', :to => :topics
      get 'topics/ordered/:ordered_index', :to => :topics, :constraints => {
        :ordered_index => /\d+/
      }
    end
  end

  mount Dashing::Engine, at: Dashing.config.engine_path

  mount Resque::Server.new, at: '/resque'

  root 'welcome#index'
end
