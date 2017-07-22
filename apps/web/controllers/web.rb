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
           calendars: ChurchCalendar.sanctorale_repository.metadata,
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
           calendars: ChurchCalendar.sanctorale_repository.metadata,
          }
      render :month, locals: l
    end

    get '/api-doc' do
      render :apidoc
    end

    get '/about' do
      render :about
    end

    get '/showcase' do
      render :showcase
    end



    def format_weekday(i)
      %w{Sun Mon Tue Wed Thu Fri Sat}[i]
    end

    def celebration_text(day, celeb)
      r = celeb.rank.short_desc
      return "#{celeb.title}#{', ' if r}#{r}"
    end

    def prepare_calendar(cal)
      @cal = ChurchCalendar.calendars[cal]
    rescue KeyError
      halt 404
    end
  end
end
