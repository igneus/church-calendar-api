require_relative 'api.rb'
require_relative 'web.rb'

run Rack::URLMap.new(
  "/" => ChurchCalendar::Web,
  "/api" => ChurchCalendar::API.new,
)
