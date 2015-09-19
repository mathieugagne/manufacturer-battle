require 'sinatra/base'
require 'useragent'

module ManufacturerBattle
  class App < Sinatra::Base
    get "/" do
      user_agent = UserAgent.parse(request.user_agent)
      @platform = user_agent.platform
      erb :"index.html"
    end

    get "/chart" do
      user_agent = UserAgent.parse(request.user_agent)
      @platform = user_agent.platform
      erb :"chart.html"
    end

    get "/assets/js/application.js" do
      content_type :js
      @scheme = ENV['RACK_ENV'] == "production" ? "wss://" : "ws://"
      erb :"application.js"
    end
  end
end