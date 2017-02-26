module ChurchCalendar

  # year of promulgation of the implemented calendar system
  CALENDAR_START = 1969
  CALENDAR_SYSTEM_DESC = {
                          promulgated: CALENDAR_START,
                          desc: "promulgated by motu proprio Mysterii Paschalis of Paul VI. (AAS 61 (1969), pp. 222-226)."
                         }

  APP_ROOT = File.expand_path '../../..', File.dirname(__FILE__)
  CALENDARS_CONFIG = File.join APP_ROOT, 'config', 'calendars.yml'
  DATA_PATH = File.join APP_ROOT, 'data'

  # languages supported
  LANGS = [:cs, :en, :it]

  @@sanctorale_repository = SanctoraleRepository.load_from CALENDARS_CONFIG, DATA_PATH
  def self.sanctorale_repository
    @@sanctorale_repository
  end
end
