require 'rack/cors'

require_relative 'api.rb'
require_relative 'web.rb'

use Rack::Cors do
  allow do
    origins '*'
    resource '/api/*', :headers => :any, :methods => :get
  end
end

run Rack::URLMap.new(
  "/" => ChurchCalendar::Web,
  "/api" => ChurchCalendar::API.new,
)
