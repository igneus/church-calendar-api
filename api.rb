require 'grape'
require 'grape-entity'
require 'yaml'
require 'calendarium-romanum'

require_relative 'app/entities/celebration.rb'
require_relative 'app/entities/day.rb'
require_relative 'app/calendarfactory.rb'
require_relative 'app/sanctoralerepository.rb'
require_relative 'app/jsonprettyprinter.rb'
require_relative 'app/churchcalendar.rb'

CR = CalendariumRomanum

module ChurchCalendar
  class API < Grape::API
    API_VERSION = 'v0'
    version API_VERSION, using: :path

    format :json
    content_type :json, 'application/json; charset=utf-8'

    formatter :json, JSONPrettyPrinter

    # to make paths consistent between testing and development/production,
    # where the app is mounted under /api
    if ENV['RACK_ENV'] == 'test'
      prefix :api
    end

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
          error! "The calendar was promulgated in #{CALENDAR_START}, #{year} is invalid year", 400
        end
      end

      def build_path(path)
        "/api/#{API_VERSION}/#{params[:lang]}" + path
      end
    end

    params do
      requires :lang, type: Symbol, values: LANGS
    end
    segment '/:lang' do

      resource :calendars do
        before do
          @repo = ChurchCalendar.sanctorale_repository
        end

        get do
          @repo.keys
        end

        segment '/:cal' do
          before do
            begin
              @factory = @repo.get_calendar_factory params[:cal]
            rescue KeyError
              error! "Requested calendar '#{params[:cal]}' not found.", 404
            end
          end

          desc 'Human-readable description of the calendar provided'
          get do
            {
             system: CALENDAR_SYSTEM_DESC,
             sanctorale: @repo.metadata(params[:cal])
            }
          end

          get 'today' do
            day = Date.today
            calendar = @factory.for_day day

            cal_day = calendar.day day
            present cal_day, with: ChurchCalendar::Day
          end

          segment '/:year' do
            before do
              @year = get_year params[:year]
              @calendar = @factory.for_year @year
            end

            get do
              {
               lectionary: @calendar.lectionary,
               ferial_lectionary: @calendar.ferial_lectionary
              }
            end

            params do
              requires :month, type: Integer, values: 1..12
            end
            segment '/:month' do
              get do
                cal = @calendar
                begin
                  days = CR::Util::Month.new(@year, params[:month]).collect do |date|
                    cal.day date
                  end
                  present days, with: ChurchCalendar::Day
                rescue RangeError
                  cal = @calendar.pred
                  retry
                end
              end

              params do
                requires :day, type: Integer, values: 1..31
              end
              get '/:day' do
                begin
                  day = Date.new @year, params[:month], params[:day]
                rescue ArgumentError
                  # year and month is already validated
                  error! 'day does not have a valid value', 400
                end
                calendar = @factory.for_day day
                year = @calendar.year

                cal_day = calendar.day @year, params[:month], params[:day]
                present cal_day, with: ChurchCalendar::Day
              end
            end
          end
        end
      end

      # calendar endpoints without calendar specification -
      # redirect all to the default calendar

      get '/today' do
        redirect build_path('/calendars/default/today'), permanent: true
      end

      segment '/:year' do
        get do
          redirect build_path("/calendars/default/#{params[:year]}"), permanent: true
        end

        segment '/:month' do
          get do
            redirect build_path("/calendars/default/#{params[:year]}/#{params[:month]}"), permanent: true
          end

          get '/:day' do
            redirect build_path("/calendars/default/#{params[:year]}/#{params[:month]}/#{params[:day]}"), permanent: true
          end
        end
      end
    end
  end
end
