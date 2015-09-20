require 'faye/websocket'
require 'thread'
require 'redis'
require 'json'
require 'erb'

module ManufacturerBattle
  class StatsCollector
    KEEPALIVE_TIME = 3600 # in seconds
    CHANNEL        = "manufacturers"

    def initialize(app)
      @app     = app
      @clients = []
      uri = URI.parse(ENV["REDISCLOUD_URL"])
      @redis = Redis.new(host: uri.host, port: uri.port, password: uri.password)
      reset_statistics
      Thread.new do
        redis_sub = Redis.new(host: uri.host, port: uri.port, password: uri.password)
        redis_sub.subscribe(CHANNEL) do |on|
          on.message do |channel, msg|
            @clients.each {|ws| ws.send(msg) }
          end
        end
      end
    end

    def call(env)
      if Faye::WebSocket.websocket?(env)
        ws = subscribe(env)

        # Return async Rack response
        ws.rack_response

      else
        @app.call(env)
      end
    end

    private

    def subscribe env
      ws = Faye::WebSocket.new(env, nil, {ping: KEEPALIVE_TIME })

      ws.on :open do |event|
        p [:open, ws.object_id]
        @clients << ws
      end

      ws.on :message do |event|
        p [:message, event.data]
        @redis.publish(CHANNEL, event.data)
        @redis.sadd('labels', event.data)
        @redis.incr(event.data)
      end

      ws.on :close do |event|
        p [:close, ws.object_id, event.code, event.reason]
        @clients.delete(ws)
      end

      ws
    end

    def reset_statistics
      @redis.del('labels')
      @redis.sadd('labels', 'iPhone')
      @redis.sadd('labels', 'Android')
      @redis.set('iPhone', 0)
      @redis.set('Android', 0)
    end

  end
end
