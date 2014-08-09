# This controller overrides the original events' controller bundled with
# dashing-rails introducing some new behavior. While the original one only
# propagate events when they happen, this version stream all the cached
# events [1] right when the connection is opened and only after that it'll
# behave like the original one, streaming events as they happen.
#
# [1] See `Dashing.send_events` at `app/analytics.rb` for more info about
# caching.

module Dashing
  class EventsController < ApplicationController
    include ActionController::Live

    respond_to :html

    def index
      response.headers['Content-Type']      = 'text/event-stream'
      response.headers['X-Accel-Buffering'] = 'no'

      @redis = Dashing.redis

      # Here we stream out events that were cached through
      # Dashing.send_event(.., :cached => true)
      @redis.keys("#{Dashing.config.redis_namespace}:*").each do |key|
        response.stream.write("data: #{@redis.get(key)}\n\n")
      end

      # Here we subscribe to redis messages emitted by our jobs and stream
      # the events
      @redis.psubscribe("#{Dashing.config.redis_namespace}.*") do |on|
        on.pmessage do |pattern, event, data|
          response.stream.write("data: #{data}\n\n")
        end
      end

    rescue IOError
      logger.info "[Dashing][#{Time.now.utc.to_s}] Stream closed"
    ensure
      @redis.quit
      response.stream.close
    end

  end
end
