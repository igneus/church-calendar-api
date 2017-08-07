require 'grape'

require_relative 'api/v0.rb'

module ChurchCalendar
  class API < Grape::API
    mount APIv0
  end
end
