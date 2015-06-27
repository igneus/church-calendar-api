ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'rack/test'
require_relative '../api'

include Rack::Test::Methods

# expected by Rack::Test methods
def app
  ChurchCalendar::API
end
