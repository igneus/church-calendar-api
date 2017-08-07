ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'rack/test'

require_relative '../lib/church-calendar'
require_relative '../apps/api'
require_relative '../apps/web'
