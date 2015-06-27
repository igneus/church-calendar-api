require_relative 'spec_helper'

require 'json'

# adds common path elements at the beginning
def api_path(path)
  '/v1' + path
end

def dejson(str)
  JSON.load str
end

# the API tested using Rack::Test
describe ChurchCalendar::API do

  describe '/calendar' do
    it 'returns object describing the calendar' do
      get api_path '/calendar'
      last_response.must_be :ok?

      r = dejson(last_response.body)
      r.must_be_kind_of Hash
      r['promulgated'].must_equal 1969
      r['title'].must_include 'calendar'
    end
  end

  describe '/today' do
    it 'returns a calendar entry' do
      get api_path '/today'
      last_response.must_be :ok?
      r = dejson last_response.body
      r['date'].must_be_kind_of String
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

        it 'has date' do
          @r['date'].must_equal '2015-06-26'
        end

        it 'has season' do
          @r['season'].must_equal 'ordinary'
        end

        it 'has celebrations' do
          skip
          @r['celebrations'].must_be_kind_of Array
        end
      end
    end
  end

  describe '/:year/:month' do
    describe 'valid date' do
      before do
        get api_path '/2015/6'
        @r = dejson last_response.body
      end

      it 'returns a list of calendar entries' do
        @r.must_be_kind_of Array
        @r[0].must_be_kind_of Hash
        @r[0]['date'].must_equal '2015-06-01'
        @r[0]['season'].must_equal 'ordinary'
        @r[-1]['date'].must_equal '2015-06-30'
      end
    end
  end
end
