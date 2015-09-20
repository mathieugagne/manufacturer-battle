require 'rubygems'
require 'bundler/setup'
require 'faye/websocket'
require 'eventmachine'

EM.run {
  # url = 'ws://localhost:5000/'
  url = 'ws://manufacturer-battle.herokuapp.com/'
  ws = Faye::WebSocket::Client.new(url)

  platforms = %w(Macintosh iPhone iPhone iPhone Android Android Android Android ChromeOS)
  timer = EM.add_periodic_timer(0.05) do
    begin
      ws.send(platforms.sample)
    rescue NoMethodError
      EM.cancel_timer(timer)
    end
  end

}
