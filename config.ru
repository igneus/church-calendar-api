require_relative 'api.rb'
require_relative 'web.rb'

# monkey-patch proposed here:
# http://ruby-lang-love.blogspot.cz/2011/09/rackurlmap-failing-with-phusion.html
class Rack::URLMap
  alias_method :old_call, :call
  def call(env)
    env["SERVER_NAME"] = env["HTTP_HOST"]
    old_call(env)
  end
end

run Rack::URLMap.new(
  "/" => ChurchCalendar::Web,
  "/api" => ChurchCalendar::API.new,
)
