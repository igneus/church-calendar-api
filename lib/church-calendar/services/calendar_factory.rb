module ChurchCalendar
  # creates Calendar instances with the same settings
  class CalendarFactory
    def initialize(*constructor_args)
      @constructor_args = constructor_args
    end

    def for_year(year)
      CalendariumRomanum::Calendar.new year, *@constructor_args
    end

    def for_day(date)
      CalendariumRomanum::Calendar.for_day date, *@constructor_args
    end
  end
end
