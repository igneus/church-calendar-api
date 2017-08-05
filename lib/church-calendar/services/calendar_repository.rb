require 'yaml'

module ChurchCalendar
  class CalendarRepository
    extend Forwardable

    def initialize(config, data_path)
      @calendars = config
      @path = data_path
    end

    def self.load_from(yaml_config_path, data_path)
      new YAML.load_file(yaml_config_path), data_path
    end

    def_delegators :@calendars, :keys, :has_key?

    def [](key)
      unless @calendars.has_key? key
        raise KeyError.new(key)
      end

      data_files = @calendars[key]['files'].collect do |f|
        File.join @path, f
      end
      sanctorale = CalendariumRomanum::SanctoraleFactory
                   .load_layered_from_files *data_files
      factory = CalendarFactory.new sanctorale

      CalendarFacade.new factory, @calendars[key]
    end

    def metadata
      @calendars
    end
  end
end
