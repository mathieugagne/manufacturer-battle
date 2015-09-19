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
      end

      ws.on :close do |event|
        p [:close, ws.object_id, event.code, event.reason]
        @clients.delete(ws)
      end

      ws
    end
  end
end
