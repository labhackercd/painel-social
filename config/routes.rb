require 'resque/server'

Rails.application.routes.draw do
  root 'welcome#index'

  resources :panels, :only => [:index, :show]

  resources :bills, :only => [:index] do
    collection do
      get 'topics(/:topic)', :to => :topics
      get 'topics/ordered/:ordered_index', :to => :topics, :constraints => {
        :ordered_index => /\d+/
      }
    end
  end

  mount Dashing::Engine, at: Dashing.config.engine_path

  mount Resque::Server.new, at: '/resque'
end
