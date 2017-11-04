require_relative 'spec_helper'

# the website tested using Rack::Test
describe ChurchCalendar::Web do
  include Rack::Test::Methods

  def app
    ChurchCalendar::Web
  end

  describe 'pages' do
    %w(/ /api-doc).each do |route|
      it route do
        get route
        last_response.must_be :ok?
      end
    end
  end

  describe 'calendar browsing' do
    describe 'calendar' do
      describe 'exists' do
        it 'shows it' do
          get '/browse/default'
          last_response.must_be :ok?
          last_response.body.must_include 'General Roman Calendar'
        end
      end

      describe 'does not exist' do
        it 'fails' do
          get '/browse/unknown'
          last_response.status.must_equal 404
        end
      end
    end

    describe 'year' do
      it 'redirects to the first month' do
        get '/browse/default/2017'
        last_response.status.must_equal 302
        last_response.headers['Location'].must_equal '/browse/default/2017/1'
      end
    end

    describe 'month' do
      describe 'happy path' do
        it 'renders month listing' do
          get '/browse/default/2017/1'
          last_response.must_be :ok?
          last_response.body.must_include '2017 / 1'
        end
      end

      describe 'unknown calendar' do
        it 'fails' do
          get '/browse/unknown/2017/1'
          last_response.status.must_equal 404
        end
      end

      describe 'invalid year' do
        describe 'numeric' do
          it 'fails' do
            get '/browse/default/1900/1'
            last_response.status.must_equal 400
          end
        end

        describe 'non-numeric' do
          it 'fails' do
            get '/browse/default/noyear/1'
            last_response.status.must_equal 404
          end
        end
      end

      describe 'invalid month' do
        it 'fails' do
          get '/browse/default/2017/100'
          last_response.status.must_equal 400
        end
      end
    end
  end
end
