require 'grape'
require 'grape-entity'
require 'yaml'
require 'calendarium-romanum'

require_relative 'app/entities/celebration.rb'
require_relative 'app/entities/day.rb'
require_relative 'app/calendarfactory.rb'

CR = CalendariumRomanum

module ChurchCalendar
  class API < Grape::API
    API_VERSION = 'v0'
    version API_VERSION, using: :path

    format :json

    # to make paths consistent between testing and development/production,
    # where the app is mounted under /api
    if ENV['RACK_ENV'] == 'test'
      prefix :api
    end

    # year of promulgation of this calendar
    # (of the calendar system, not of any particular sanctorale data set)
    CALENDAR_START = 1969

    # languages supported
    LANGS = [:en]

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
          error! "Bad Request: The calendar was promulgated in #{CALENDAR_START}, #{year} is invalid year", 400
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
        get do
          []
        end

        segment '/:cal' do
          before do
            begin
              sanctorale_files = File.join(File.dirname(__FILE__), 'data', YAML.load_file('config/calendars.yml')[params[:cal]])
              @factory = CalendarFactory.new sanctorale_files
            rescue Errno::ENOENT
              error! "Requested calendar '#{params[:cal]}' not found.", 404
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
                  CR::Util::Month.new(@year, params[:month]).collect do |date|
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
