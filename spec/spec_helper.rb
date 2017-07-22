ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'rack/test'

require_relative '../lib/church-calendar'
require_relative '../apps/api/v0'
require_relative '../apps/web'
