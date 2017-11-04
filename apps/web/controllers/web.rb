require 'roda'
require 'haml'

module ChurchCalendar
  class Web < Roda
    plugin :render,
           engine: 'haml',
           layout: '_layout',
           views: File.expand_path('../../views', __FILE__)
    plugin :sinatra_helpers,
           delegate: false
    plugin :public
    plugin :halt

    route do |r|
      r.root do
        view :index
      end

      # serve public assets from /public
      r.public

      r.on 'browse' do
        r.is do
          r.redirect '/browse/default'
        end

        r.on String do |cal|
          begin
            @cal = ChurchCalendar.calendars[cal]
            I18n.locale = @cal.metadata['language']
          rescue KeyError
            r.halt 404
          end

          r.is do
            start_year = Time.now.year - 5
            end_year = start_year + 10
            l = {
              start_year: start_year,
              end_year: end_year,
              today: Date.today,
              cal: cal,
              calendars: ChurchCalendar.calendars.metadata,
            }
            view :browse, locals: l
          end

          r.on Integer do |year|
            r.is do
              r.redirect "/browse/#{cal}/#{year}/1"
            end

            r.on Integer do |month|
              r.is do
                begin
                  month_enumerator = CalendariumRomanum::Util::Month.new(year, month)
                rescue ArgumentError
                  r.halt 400
                end

                begin
                  entries = month_enumerator.collect do |date|
                    @cal.day(date)
                  end
                rescue RangeError
                  r.halt 400
                end

                l = {
                  year: year,
                  month: month,
                  entries: entries,
                  cal: cal,
                  calendars: ChurchCalendar.calendars.metadata,
                }
                view :month, locals: l
              end
            end
          end
        end
      end

      r.is 'api-doc' do
        view :apidoc
      end

      r.is 'swagger.yml' do
        locals = {
          email: ChurchCalendar.parameters['contact']['email'],
          docs_url: request.uri('api-doc'),
          effectiveness_year: ChurchCalendar::CALENDAR_START,
          calendar_ids: ChurchCalendar.calendars.keys,
          langs: ChurchCalendar::LANGS.collect(&:to_s),
        }
        render :'swagger.yml', engine: :erb, locals: locals
      end

      r.is 'about' do
        parameters = ChurchCalendar.parameters
        locals = {
          maintainer: parameters['contact']['name'],
          email: parameters['contact']['email'],
        }
        view :about, locals: locals
      end
    end
  end
end
