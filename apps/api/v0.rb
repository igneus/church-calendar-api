require 'grape'
require 'grape-entity'

I18n.backend.load_translations

require_relative 'v0/entities/celebration.rb'
require_relative 'v0/entities/day.rb'

require_relative 'v0/controllers/api'
