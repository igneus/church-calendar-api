require 'oj'
require 'multi_json'

module ChurchCalendar
  class API < Grape::API
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
        get do
          ChurchCalendar.calendars.keys
        end

        segment '/:cal' do
          before do
            begin
              @calendar = ChurchCalendar.calendars[params[:cal]]
            rescue KeyError
              error! "Requested calendar '#{params[:cal]}' not found.", 404
            rescue ChurchCalendar::UnknownCalendarError => err
              error! err.message, 404
            end
          end

          desc 'Human-readable description of the calendar provided'
          get do
            {
             system: CALENDAR_SYSTEM_DESC,
             sanctorale: @calendar.metadata
            }
          end

          get 'yesterday' do
            day = Date.yesterday
            cal_day = @calendar.day day
            present cal_day, with: ChurchCalendar::Day
          end

          get 'today' do
            day = Date.today
            cal_day = @calendar.day day
            present cal_day, with: ChurchCalendar::Day
          end

          get 'tomorrow' do
            day = Date.tomorrow
            cal_day = @calendar.day day
            present cal_day, with: ChurchCalendar::Day
          end

          segment '/:year' do
            before do
              @year = get_year params[:year]
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
