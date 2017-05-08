module ChurchCalendar
  class CalendarRepository
    def initialize(sanctorale_repo)
      @sanctorale_repo = sanctorale_repo
    end

    def [](key)
      unless @sanctorale_repo.has_key? key
        raise KeyError.new(key)
      end

      CalendarFacade.new key, @sanctorale_repo
    end

    def keys
      @sanctorale_repo.keys
    end
  end
end
