require 'grape'
require 'grape-entity'
require 'calendarium-romanum'

require_relative 'app/entities/day'

module ChurchCalendar
  class API < Grape::API
    version 'v1', using: :path
    format :json

    # year of promulgation of this calendar
    CALENDAR_START = 1969

    helpers do
      def get_year(s)
        if s == 'current'
          return Time.now.year
        end

        year = s.to_i
        validate_year! year
        return year
      end

      def validate_year!(year)
        if year < CALENDAR_START
          raise ValueError.new "The calendar was promulgated in #{CALENDAR_START}, #{year} is invalid year"
        end
      end
    end

    desc 'Human-readable specification of the calendar provided'
    get '/calendar' do
      {
       title: 'Roman Catholic general liturgical calendar',
       desc: "promulgated by MP Mysterii Paschalis of Paul VI. (AAS 61 (1969), pp. 222-226).\nImplementation incomplete and buggy.",
       promulgated: CALENDAR_START
      }
    end

    get 'today' do
      day = Date.today
      calendar = CalendariumRomanum::Calendar.for_day day

      cal_day = calendar.day day
      present cal_day, with: ChurchCalendar::Day
    end

    segment '/:year' do
      before do
        @year = get_year params[:year]
        @calendar = CalendariumRomanum::Calendar.new @year
      end

      get '/' do
        {
         lectionary: @calendar.lectionary,
         ferial_lectionary: @calendar.ferial_lectionary
        }
      end

      params do
        requires :month, type: Integer, values: 1..12
      end
      segment '/:month' do
        get '/' do
          cal = @calendar
          begin
            CalendariumRomanum::Month.new(@year, params[:month]).collect do |date|
              cal.day date
            end
          rescue RangeError
            cal = @calendar.pred
            retry
          end
        end

        params do
          requires :day, type: Integer, values: 1..31
        end
        get '/:day' do
          day = Date.new @year, params[:month], params[:day]
          calendar = CalendariumRomanum::Calendar.for_day day
          year = @calendar.year

          cal_day = calendar.day @year, params[:month], params[:day]
          present cal_day, with: ChurchCalendar::Day
        end
      end
    end
  end
end
