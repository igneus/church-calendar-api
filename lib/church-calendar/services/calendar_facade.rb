module ChurchCalendar
  # Encapsulates the logic of finding a liturgical year
  # for date specified in terms of a civic year.
  # Exposes a comfortable interface for calendar querying.
  class CalendarFacade
    def initialize(key, sanctorale_repo)
      @metadata = sanctorale_repo.metadata key
      @calendar_factory = sanctorale_repo.get_calendar_factory key
    end

    attr_reader :metadata

    def day(date)
      calendar = @calendar_factory.for_day date
      calendar.day date
    end

    def days_of_month(year, month)
      calendar = @calendar_factory.for_year year
      month_enum = CR::Util::Month.new(year, month)

      range_errors = 0
      month_enum.each_with_index.collect do |date, i|
        begin
          calendar.day date
        rescue RangeError
          range_errors += 1
          raise if range_errors > 2

          # range error at the first day means we are
          # in a wrong liturgical year;
          # range error in the middle means that end of a
          # liturgical year was reached
          calendar = (i == 0) ? calendar.pred : calendar.succ
          retry
        end
      end
    end

    def year(year)
      @calendar_factory.for_year year
    end
  end
end
