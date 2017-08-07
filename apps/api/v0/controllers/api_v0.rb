require 'oj'
require 'multi_json'

module ChurchCalendar
  class APIv0 < Grape::API
    include Grape::Extensions::Hash::ParamBuilder

    API_VERSION = 'v0'
    version API_VERSION, using: :path

    format :json
    content_type :json, 'application/json; charset=utf-8'

    formatter :json, -> (obj, env) { MultiJson.dump(obj, pretty: true) }

    # to make paths consistent between testing and development/production,
    # where the app is mounted under /api
    if ENV['RACK_ENV'] == 'test'
      prefix :api
    end

    helpers do
      def build_path(path)
        "/api/#{API_VERSION}/#{params[:lang]}" + path
      end

      # parses content of HTTP header Date
      def parse_date(date=nil)
        if date
          begin
            Date.parse date
          rescue ArgumentError
            error! 'invalid content of HTTP header Date', 400
          end
        else
          Date.today
        end
      end
    end

    params do
      requires :lang, type: Symbol, values: LANGS
    end
    segment '/:lang' do
      after_validation do
        I18n.locale = params[:lang]
      end

      resource :calendars do
        get do
          ChurchCalendar.calendars.keys
        end

        params do
          requires :calendar, type: String, values: ->(v) { ChurchCalendar.calendars.has_key?(v) }
        end
        segment '/:calendar' do
          after_validation do
            @calendar = ChurchCalendar.calendars[params[:calendar]]
          end

          desc 'Human-readable description of the calendar provided'
          get do
            {
             system: CALENDAR_SYSTEM_DESC,
             sanctorale: @calendar.metadata
            }
          end

          get 'yesterday' do
            day = parse_date(headers['Date']) - 1
            cal_day = @calendar.day day
            present cal_day, with: ChurchCalendar::Day
          end

          get 'today' do
            day = parse_date(headers['Date'])
            cal_day = @calendar.day day
            present cal_day, with: ChurchCalendar::Day
          end

          get 'tomorrow' do
            day = parse_date(headers['Date']) + 1
            cal_day = @calendar.day day
            present cal_day, with: ChurchCalendar::Day
          end

          params do
            requires :year, type: Integer, values: {value: ->(v) { v >= ChurchCalendar::CALENDAR_START }, message: "invalid, the calendar was promulgated in #{CALENDAR_START}"}
          end
          segment '/:year' do
            after_validation do
              @year = params[:year]
            end

            get do
              year = @calendar.year @year
              {
               lectionary: year.lectionary,
               ferial_lectionary: year.ferial_lectionary
              }
            end

            params do
              requires :month, type: Integer, values: 1..12
            end
            segment '/:month' do
              get do
                days = @calendar.days_of_month @year, params[:month]
                present days, with: ChurchCalendar::Day
              end

              params do
                requires :day, type: Integer, values: 1..31
              end
              get '/:day' do
                begin
                  # check the date is valid
                  day = Date.new @year, params[:month], params[:day]
                rescue ArgumentError
                  # year and month is already validated, so the error is definitely about day
                  error! 'day does not have a valid value', 400
                end

                cal_day = @calendar.day day
                present cal_day, with: ChurchCalendar::Day
              end
            end
          end
        end
      end

      # calendar endpoints without calendar specification -
      # redirect all to the default calendar

      get '/yesterday' do
        redirect build_path('/calendars/default/yesterday'), permanent: true
      end

      get '/today' do
        redirect build_path('/calendars/default/today'), permanent: true
      end

      get '/tomorrow' do
        redirect build_path('/calendars/default/tomorrow'), permanent: true
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
