require 'i18n'
require 'i18n/backend/fallbacks'
require 'yaml'
require 'calendarium-romanum'

require_relative 'church-calendar/services/calendar_factory.rb'
require_relative 'church-calendar/services/sanctorale_repository.rb'
require_relative 'church-calendar/models/church_calendar.rb'

CR = CalendariumRomanum

I18n::Backend::Simple.include I18n::Backend::Fallbacks
I18n.backend.load_translations
