web:        bundle exec rails s
scheduler:  TERM_CHILD=1 bundle exec rake environment resque:scheduler
worker:     TERM_CHILD=1 bundle exec rake environment resque:work QUEUE=panels,causabrasil,twitter,analytics
