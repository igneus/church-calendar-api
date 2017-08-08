require_relative 'spec_helper'

require 'json'

# adds common path elements at the beginning
def api_path(path, lang=:en, cal='/calendars/default')
  "/api/v0/#{lang}#{cal}" + path
end

def dejson(str)
  JSON.load str
end

# shared examples describing day entry.
# They expect a method day_entry returning a described day entry.
module DayEntryFormatExamples
  extend Minitest::Spec::DSL

  it 'contains expected fields in expected format' do
    day_entry['date'].must_match /^\d{4}-\d{2}-\d{2}$/
    day_entry['season'].must_match /^\w+$/
    day_entry['season_week'].must_be_kind_of Integer
    day_entry['weekday'].must_match /^\w+$/

    day_entry['celebrations'].must_be_kind_of Array
    day_entry['celebrations'].wont_be :empty?

    c = day_entry['celebrations'][0]
    c['title'].must_be_kind_of String
    c['colour'].must_match /^\w+$/
    c['rank'].must_match /^[\w\s]+$/
    c['rank_num'].must_be_kind_of Float
  end
end

# the API tested using Rack::Test
describe ChurchCalendar::APIv0 do
  include Rack::Test::Methods

  # expected by Rack::Test methods
  def app
    ChurchCalendar::APIv0
  end

  describe 'language' do
    describe 'supported languages' do
      it 'Czech' do
        get '/api/v0/cs/calendars/default/today'
        last_response.must_be :ok?
      end

      it 'English' do
        get '/api/v0/en/calendars/default/today'
        last_response.must_be :ok?
      end

      it 'Italian' do
        get '/api/v0/it/calendars/default/today'
        last_response.must_be :ok?
      end
    end

    it 'unsupported language results in an error' do
      get '/api/v0/xx/calendars/default/today'
      last_response.wont_be :ok?
      last_response.status.must_equal 400
      r = dejson last_response.body
      r['error'].must_equal 'lang does not have a valid value'
    end
  end

  describe '/calendars' do
    it 'returns list of calendars available' do
      get '/api/v0/en/calendars'
      last_response.must_be :ok?
      dejson(last_response.body)
        .must_equal %w(general-en general-la general-it czech czech-cechy czech-morava czech-pha czech-ltm czech-hk czech-cb czech-plz czech-olm czech-brn czech-oo default)
    end

    it 'all calendars work' do
      get '/api/v0/en/calendars'
      last_response.must_be :ok?
      dejson(last_response.body).each do |cal|
        get "/api/v0/en/calendars/#{cal}/2011/10/9"
        last_response.must_be :ok?
      end
    end
  end

  describe '/calendars/:cal' do
    it 'returns calendar description' do
      get '/api/v0/en/calendars/default'
      last_response.must_be :ok?
      dejson(last_response.body)
        .must_equal({
                      'system' => {
                        'promulgated' => 1969,
                        'desc' => 'promulgated by motu proprio Mysterii Paschalis of Paul VI. (AAS 61 (1969), pp. 222-226).'
                      },
                      'sanctorale' => {
                        'title' => 'General Roman Calendar',
                        'language' => 'en'
                      }
                    })
    end
  end

  describe '/calendars/:cal' do
    it 'returns calendar description' do
      get '/api/v0/en/calendars/unknown'
      last_response.status.must_equal 400
      dejson(last_response.body)['error'].must_equal 'calendar does not have a valid value'
    end
  end

  describe '/' do
    it 'returns object describing the calendar' do
      get api_path '/'
      last_response.must_be :ok?

      r = dejson(last_response.body)
      r.must_be_kind_of Hash
      r['system']['promulgated'].must_equal 1969
      r['sanctorale']['title'].must_include 'Calendar'
    end
  end

  %w(/today /tomorrow /yesterday).each do |route|
    describe route do
      before do
        get api_path route
        @r = dejson last_response.body
      end

      def day_entry
        @r
      end

      include DayEntryFormatExamples

      it 'returns a calendar entry' do
        last_response.must_be :ok?
        @r['date'].must_be_kind_of String
      end
    end
  end

  describe '/today and friends honor HTTP header Date' do
    describe 'preferred date format' do
      it 'returns entry of the specified day' do
        header 'Date', 'Sat, 01 Jan 2000 01:00:00 GMT'
        get api_path '/today'
        last_response.must_be :ok?
        dejson(last_response.body)['date'].must_equal '2000-01-01'
      end
    end

    describe 'legacy date format: RFC 850' do
      it 'returns entry of the specified day' do
        header 'Date', 'Saturday, 01-Jan-00 01:00:00 GMT'
        get api_path '/today'
        last_response.must_be :ok?
        dejson(last_response.body)['date'].must_equal '2000-01-01'
      end
    end

    describe 'legacy date format: ANSI C asctime()' do
      it 'returns entry of the specified day' do
        header 'Date', 'Sat Jan  1 01:00:00 2000'
        get api_path '/today'
        last_response.must_be :ok?
        dejson(last_response.body)['date'].must_equal '2000-01-01'
      end
    end

    describe 'unsupported date format' do
      it 'fails with a helpful message' do
        header 'Date', 'invalid date'
        get api_path '/today'
        last_response.status.must_equal 400
        dejson(last_response.body)['error'].must_equal 'invalid content of HTTP header Date'
      end
    end
  end

  describe '/year' do
    it 'contains basic per-year "liturgical setup"' do
      get api_path '/2014'
      last_response.must_be :ok?
      dejson(last_response.body).must_equal({'lectionary' => 'B', 'ferial_lectionary' => 1})
    end
  end

  describe '/:year/:month/:day' do
    describe 'valid date' do
      describe 'simple ferial' do
        before do
          get api_path '/2015/6/26'
          @r = dejson last_response.body
        end

        def day_entry
          @r
        end

        include DayEntryFormatExamples

        it 'has date' do
          @r['date'].must_equal '2015-06-26'
        end

        it 'has season' do
          @r['season'].must_equal 'ordinary'
        end

        it 'has celebrations' do
          c = @r['celebrations']
          c.must_be_kind_of Array
          c.size.must_equal 1

          c[0]['colour'].must_equal 'green'

          c[0]['rank'].must_equal 'ferial'
        end

        it 'has weekday' do
          # of course this can be obtained from the date, but
          # user-readability is a value
          @r['weekday'].must_equal 'friday'
        end
      end

      describe 'Sunday' do
        before do
          get api_path '/2016/9/25'
          @r = dejson last_response.body
        end

        def day_entry
          @r
        end

        include DayEntryFormatExamples
      end

      describe 'memorial' do
        before do
          get api_path '/2015/6/11'
          @r = dejson last_response.body
        end

        it 'has sanctorale celebrations' do
          c = @r['celebrations']
          c.size.must_equal 1
          c[0]['rank'].must_equal 'memorial'
          c[0]['title'].must_equal 'Saint Barnabas the Apostle'
        end
      end
    end

    describe 'example year' do
      year = 2000

      it 'is a leap year' do
        Date.new(year).must_be :leap?
      end

      describe 'all months' do
        (1..12).each do |month|
          path = "/#{year}/#{month}"

          it path do
            get api_path path
            last_response.must_be :ok?
          end
        end
      end

      describe 'all days' do
        CalendariumRomanum::Util::Year.new(year).each do |date|
          path = "/#{date.year}/#{date.month}/#{date.day}"

          it path do
            get api_path path
            last_response.must_be :ok?
          end
        end
      end
    end

    describe 'invalid date' do
      it 'invalid month returns bad request' do
        get api_path '/2015/13/1'
        last_response.status.must_equal 400
        dejson(last_response.body)['error'].must_equal 'month does not have a valid value'
      end

      it 'invalid year (too old) returns bad request' do
        get api_path '/1950/12/1'
        last_response.status.must_equal 400
        dejson(last_response.body)['error'].must_equal 'year invalid, the calendar was promulgated in 1969'
      end

      it 'invalid day - generally' do
        get api_path '/2015/2/39'
        last_response.status.must_equal 400
        dejson(last_response.body)['error'].must_equal 'day does not have a valid value'
      end

      it 'invalid day - for the month specifically' do
        get api_path '/2015/2/29'
        last_response.status.must_equal 400
        dejson(last_response.body)['error'].must_equal 'day does not have a valid value'
      end
    end
  end

  describe '/:year/:month' do
    describe 'valid month' do
      before do
        get api_path '/2015/6'
        @r = dejson last_response.body
      end

      def day_entry
        @r.first
      end

      include DayEntryFormatExamples

      it 'returns a list of calendar entries' do
        @r.must_be_kind_of Array
        @r[0].must_be_kind_of Hash
        @r[0]['date'].must_equal '2015-06-01'
        @r[0]['season'].must_equal 'ordinary'
        @r[-1]['date'].must_equal '2015-06-30'
      end
    end

    describe 'invalid month' do
      it 'fails' do
        get api_path '/2015/14'
        last_response.status.must_equal 400
        r = dejson last_response.body
        r['error'].must_equal 'month does not have a valid value'
      end
    end

    describe 'month where liturgical and civic year differ' do
      it 'works' do
        get api_path '/2015/1'
        last_response.must_be :ok?
      end
    end

    describe 'month where a new liturgical year begins' do
      it 'works' do
        get api_path '/2016/11'
        last_response.must_be :ok?
      end
    end
  end

  describe 'requests not qualified by calendar redirect to default calendar' do
    it '/today' do
      get '/api/v0/en/today'
      follow_redirect!
      last_request.url.must_equal 'http://example.org/api/v0/en/calendars/default/today'
      last_response.must_be :ok?
    end

    it '/year' do
      get '/api/v0/en/2014'
      follow_redirect!
      last_request.url.must_equal 'http://example.org/api/v0/en/calendars/default/2014'
      last_response.must_be :ok?
    end

    it '/year/month' do
      get '/api/v0/en/2014/5'
      follow_redirect!
      last_request.url.must_equal 'http://example.org/api/v0/en/calendars/default/2014/5'
      last_response.must_be :ok?
    end

    it '/year/month/day' do
      get '/api/v0/en/2014/5/5'
      follow_redirect!
      last_request.url.must_equal 'http://example.org/api/v0/en/calendars/default/2014/5/5'
      last_response.must_be :ok?
    end
  end

  describe 'unknown route' do
    it 'is handled properly' do
      get '/api/unknown_route'
      last_response.status.must_equal 404
    end
  end
end
