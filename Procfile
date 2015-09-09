web:        bin/rails server -p $PORT -e $RAILS_ENV
scheduler:  TERM_CHILD=1 VVERBOSE=1 bundle exec rake environment resque:scheduler
worker:     TERM_CHILD=1 VVERBOSE=1 QUEUES='*' bundle exec rake environment resque:work
