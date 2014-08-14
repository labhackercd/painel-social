Rails.application.routes.draw do
  mount Dashing::Engine, at: Dashing.config.engine_path

  root 'welcome#index'
end
