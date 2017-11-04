require 'yaml'

module ChurchCalendar
  class CalendarRepository
    extend Forwardable

    def initialize(config, data_path)
      @calendars = config
      @path = data_path

      @sanctorale_loader = CalendariumRomanum::SanctoraleLoader.new
    end

    def self.load_from(yaml_config_path, data_path)
      new YAML.load_file(yaml_config_path), data_path
    end

    def_delegators :@calendars, :keys, :has_key?

    def [](key)
      unless @calendars.has_key? key
        raise KeyError.new(key)
      end

      calendar_config = @calendars[key]
      data = calendar_config['sanctorale'].collect do |data_spec|
        load_data data_spec
      end
      sanctorale = CalendariumRomanum::SanctoraleFactory
                   .create_layered(*data)
      temporale_options = calendar_config['temporale_extensions'] &&
          build_temporale_options(calendar_config['temporale_extensions'])
      factory = CalendariumRomanum::PerpetualCalendar.new sanctorale: sanctorale, temporale_options: temporale_options

      CalendarFacade.new factory, calendar_config
    end

    def metadata
      @calendars
    end

    private

    def load_data(data_spec)
      if filename = data_spec['file']
        @sanctorale_loader.load_from_file File.join(@path, filename)
      elsif packaged = data_spec['packaged']
        CalendariumRomanum::Data[packaged].load
      else
        raise RuntimeError.new("Invalid data source specification #{data_spec.inspect}")
      end
    end

    def build_temporale_options(extensions)
      {
        extensions: extensions.collect do |name|
          "CalendariumRomanum::Temporale::Extensions::#{name}".constantize
        end
      }
    end
  end
end
