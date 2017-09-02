module ChurchCalendar
  # perpetual calendar + additional methods + metadata
  class CalendarFacade
    def initialize(perpetual_calendar, metadata)
      @perpetual_calendar = perpetual_calendar
      @metadata = metadata
    end

    attr_reader :metadata

    def day(date)
      @perpetual_calendar.day date
    end

    def days_of_month(year, month)
      month_enum = CR::Util::Month.new(year, month)

      month_enum.collect {|date| @perpetual_calendar.day date }
    end

    def year(year)
      @perpetual_calendar.calendar_for_year year
    end
  end
end
