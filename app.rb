require 'sinatra/base'
require 'useragent'

module ManufacturerBattle

  Manufacturer = Struct.new(:label, :value)

  class App < Sinatra::Base
    get "/" do
      user_agent = UserAgent.parse(request.user_agent)
      @platform = user_agent.platform
      erb :"index.html"
    end

    get "/assets/js/application.js" do
      content_type :js
      @scheme = ENV['RACK_ENV'] == "production" ? "wss://" : "ws://"
      erb :"application.js"
    end

    get "/assets/js/manufacturers.js" do
      content_type :js
      uri = URI.parse(ENV["REDISCLOUD_URL"])
      @redis = Redis.new(host: uri.host, port: uri.port, password: uri.password)

      @manufacturers = @redis.smembers('labels').collect do |label|
        Manufacturer.new(label, @redis.get(label))
      end
      erb :"manufacturers.js"
    end
  end

end
