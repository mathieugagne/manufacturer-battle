require 'rubygems'
require 'bundler/setup'
require 'faye/websocket'
require 'eventmachine'

EM.run {
  url = 'ws://localhost:5000/'
  ws = Faye::WebSocket::Client.new(url)

  platforms = %w(Linux Macintosh Windows Other)
  timer = EM.add_periodic_timer(0.1) do
    begin
      ws.send(platforms.sample)
    rescue NoMethodError
      EM.cancel_timer(timer)
    end
  end

}
