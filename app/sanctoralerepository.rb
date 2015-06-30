require 'yaml'

module ChurchCalendar

  # knows what the content of config/calendars.yml means
  # and how to use it's content to create well configured
  # CalendarFactory
  class SanctoraleRepository

    def initialize(config, data_path)
      @calendars = config
      @path = data_path
    end

    def self.load_from(yaml_config_path, data_path)
      new YAML.load_file(yaml_config_path), data_path
    end

    # returns a CalendarFactory creating Calendars
    # with a specified Sanctorale
    def get_calendar_factory(key)
      CalendarFactory.new *data_files(key)
    end

    # list of available calendars
    def keys
      @calendars.keys
    end

    # Array of data files for the given calendar;
    # should be loaded over each other in the given order
    def data_files(key)
      @calendars[key]['files'].collect do |f|
        File.join @path, f
      end
    end

    # metadata for the given calendar -
    # or for all if calendar key not specified
    def metadata(key=nil)
      if key.nil?
        # return Hash {key: metadata(key)}
        return keys.inject({}) {|memo, (k, v)| memo[k] = metadata k; memo}
      end

      m = @calendars[key].dup
      m.delete 'files'
      return m
    end
  end
end
