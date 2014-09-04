require 'resque/tasks'
require 'resque/scheduler/tasks'

namespace :resque do
  task :setup do
    require 'resque'
    require 'resque/scheduler'

    Resque.redis = Dashing.redis

    Resque.schedule = YAML.load_file("#{Rails.root}/app/jobs/schedule.yml")
  end
end
