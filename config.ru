require_relative 'api.rb'
require_relative 'web.rb'

map "/api" do
  run ChurchCalendar::API
end

map "/" do
  run ChurchCalendar::Web
end
