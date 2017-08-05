module ChurchCalendar

  # creates Calendar instances with the same Sanctorale
  class CalendarFactory

    # Expects a list of paths to Sanctorale data files.
    # All will be loaded in the given order, eventually overwritting
    # entries of each other, the last one having the last word.
    # The resulting Sanctorale will be provided to all Calendars
    # created here.
    def initialize(*sanctorales)
      @sanctorale = CalendariumRomanum::SanctoraleFactory
                    .load_layered_from_files(*sanctorales)
    end

    def for_year(year)
      CalendariumRomanum::Calendar.new year, @sanctorale
    end

    def for_day(date)
      CalendariumRomanum::Calendar.for_day date, @sanctorale
    end
  end
end
