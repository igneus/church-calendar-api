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
describe ChurchCalendar::API do

  describe 'language' do
    it 'supported language is ok' do
      get '/api/v0/en/calendars/default/today'
      last_response.must_be :ok?
    end

    it 'unsupported language results in an error' do
      get '/api/v0/xx/calendars/default/today'
      last_response.wont_be :ok?
      last_response.status.must_equal 400
    end
  end

  describe '/calendars' do
    it 'returns list of calendars available' do
      get '/api/v0/en/calendars'
      last_response.must_be :ok?
      dejson(last_response.body).must_equal ['default']
    end
  end

  describe '/' do
    it 'returns object describing the calendar' do
      get api_path '/'
      last_response.must_be :ok?

      r = dejson(last_response.body)
      r.must_be_kind_of Hash
      r['promulgated'].must_equal 1969
      r['title'].must_include 'calendar'
    end
  end

  describe '/today' do
    before do
      get api_path '/today'
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

      describe 'compose_text' do
        it 'adds a new field' do
          get api_path '/today?compose_text=true'
          r = dejson last_response.body
          r['celebrations'][0]['text'].must_be_kind_of String
        end

        it 'simple ferial' do
          get api_path '/2015/6/26?compose_text=true'
          last_response.must_equal 'Friday of the 12th week in Ordinary Time'
        end
      end
    end

    describe 'invalid date' do
      it 'invalid month returns bad request' do
        get api_path '/2015/13/1'
        last_response.status.must_equal 400
      end

      it 'invalid year (too old) returns bad request' do
        get api_path '/1950/12/1'
        last_response.status.must_equal 400
      end
    end
  end

  describe '/:year/:month' do
    describe 'valid date' do
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
end
