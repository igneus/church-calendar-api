ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'rack/test'

require_relative '../lib/church-calendar'
require_relative '../apps/api/v0'

include Rack::Test::Methods

# expected by Rack::Test methods
def app
  ChurchCalendar::API
end
