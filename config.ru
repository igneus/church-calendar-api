require 'rack/cors'
require 'rack/contrib/response_headers'

require_relative 'api.rb'
require_relative 'web.rb'

use Rack::Cors do
  allow do
    origins '*'
    resource '/api/*', :headers => :any, :methods => :get
  end
end

# allow caching everything for an hour
use Rack::ResponseHeaders do |headers|
  headers['Cache-Control'] = 'max-age=3600'
end

run Rack::URLMap.new(
  "/" => ChurchCalendar::Web,
  "/api" => ChurchCalendar::API.new,
)
