module ChurchCalendar
  class CalendarRepository
    extend Forwardable

    def initialize(sanctorale_repo)
      @sanctorale_repo = sanctorale_repo
    end

    def [](key)
      unless @sanctorale_repo.has_key? key
        raise KeyError.new(key)
      end

      calendar_factory = @sanctorale_repo.get_calendar_factory key
      metadata = @sanctorale_repo.metadata key

      CalendarFacade.new calendar_factory, metadata
    end

    def_delegators :@sanctorale_repo, :keys, :has_key?
  end
end
