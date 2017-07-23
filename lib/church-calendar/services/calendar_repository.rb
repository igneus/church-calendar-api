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

      CalendarFacade.new key, @sanctorale_repo
    end

    def_delegators :@sanctorale_repo, :keys, :has_key?
  end
end
