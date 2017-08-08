require 'scorched'
require 'haml'

module ChurchCalendar
  class Web < Scorched::Controller
    include CalendariumRomanum

    config << {
      static_dir: 'public'
    }
    render_defaults << {
      dir: File.expand_path('../views', File.dirname(__FILE__)),
      layout: :_layout,
      engine: :haml
    }

    get '/' do
      render :index
    end

    get '/browse' do
      redirect '/browse/default'
    end

    get '/browse/:cal' do |cal|
      prepare_calendar(cal)

      start_year = Time.now.year - 5
      end_year = start_year + 10
      l = {
           start_year: start_year,
           end_year: end_year,
           today: Date.today,
           cal: cal,
           calendars: ChurchCalendar.calendars.metadata,
          }
      render :browse, locals: l
    end

    get '/browse/:cal/:year' do |cal,year|
      redirect "/browse/#{cal}/#{year}/1"
    end

    get '/browse/:cal/:year/:month' do |cal, year, month|
      numeric = /\A\d+\Z/
      unless year =~ numeric && month =~ numeric
        halt 400
      end

      year = year.to_i
      month = month.to_i

      prepare_calendar(cal)

      begin
        month_enumerator = CalendariumRomanum::Util::Month.new(year, month)
      rescue ArgumentError
        halt 400
      end

      entries = month_enumerator.collect do |date|
        @cal.day(date)
      end

      l = {
           year: year,
           month: month,
           entries: entries,
           cal: cal,
           calendars: ChurchCalendar.calendars.metadata,
          }
      render :month, locals: l
    end

    get '/api-doc' do
      render :apidoc
    end

    get '/swagger.yml' do
      locals = {
        email: ChurchCalendar.parameters['contact']['email'],
        docs_url: url('api-doc'),
        promulgation_year: ChurchCalendar::CALENDAR_START,
        calendar_ids: ChurchCalendar.calendars.keys,
      }
      render :'swagger.yml', engine: :erb, locals: locals, layout: nil
    end

    get '/about' do
      parameters = ChurchCalendar.parameters
      locals = {
        maintainer: parameters['contact']['name'],
        email: parameters['contact']['email'],
      }
      render :about, locals: locals
    end



    def prepare_calendar(cal)
      @cal = ChurchCalendar.calendars[cal]
      I18n.locale = @cal.metadata['language']
    rescue KeyError
      halt 404
    end
  end
end
