# coding: utf-8
require_relative 'spec_helper'

describe ChurchCalendar::CalendarRepository do
  describe 'configuration handling' do
    describe 'empty' do
      subject { ChurchCalendar::CalendarRepository.new({}, '') }

      it 'has no keys' do
        subject.keys.must_equal []
      end
    end

    describe 'sanctorale data from file' do
      subject do
        config = {
          'general-en' => {
            'sanctorale' => [{'file' =>'universal-en.txt'}]
          }
        }

        ChurchCalendar::CalendarRepository.new(config, ChurchCalendar::DATA_PATH)
      end

      it 'can load the calendar' do
        calendar = subject['general-en']
        calendar.must_be_kind_of ChurchCalendar::CalendarFacade

        # sanctorale data are really loaded
        day = calendar.day(Date.new(2017, 8, 6))
        day.celebrations[0].title.must_equal 'Transfiguration of the Lord'
      end
    end

    describe 'packaged sanctorale data' do
      subject do
        config = {
          'general-it' => {
            'sanctorale' => [{'packaged' => 'universal-it'}]
          }
        }

        ChurchCalendar::CalendarRepository.new(config, ChurchCalendar::DATA_PATH)
      end

      it 'can load the calendar' do
        calendar = subject['general-it']
        calendar.must_be_kind_of ChurchCalendar::CalendarFacade

        # sanctorale data are really loaded
        day = calendar.day(Date.new(2017, 8, 6))
        day.celebrations[0].title.must_equal 'Trasfigurazione del Signore'
      end
    end

    describe 'layered sanctorale' do
      subject do
        config = {
          'czech-praha' => {
            'sanctorale' => [
              {'packaged' => 'czech-cs'},
              {'packaged' => 'czech-cechy-cs'},
              {'packaged' => 'czech-praha-cs'},
            ]
          }
        }

        ChurchCalendar::CalendarRepository.new(config, ChurchCalendar::DATA_PATH)
      end

      it 'can load the calendar' do
        calendar = subject['czech-praha']
        calendar.must_be_kind_of ChurchCalendar::CalendarFacade

        # all three layers are really loaded
        day = calendar.day(Date.new(2017, 8, 6))
        day.celebrations[0].title.must_equal 'Proměnění Páně'

        day = calendar.day(Date.new(2017, 7, 4))
        day.celebrations[0].title.must_equal 'Sv. Prokopa, opata'

        day = calendar.day(Date.new(2017, 5, 12))
        day.celebrations[0].title.must_match /Výročí posvěcení katedrály/
      end
    end

    describe 'temporale extension' do
      subject do
        config = {
          'czech' => {
            'sanctorale' => [{'packaged' => 'czech-cs'}],
            'temporale_extensions' => ['ChristEternalPriest']
          }
        }

        ChurchCalendar::CalendarRepository.new(config, ChurchCalendar::DATA_PATH)
      end

      it 'can load the calendar' do
        calendar = subject['czech']
        calendar.must_be_kind_of ChurchCalendar::CalendarFacade

        # the extension is applied
        I18n.with_locale(:cs) do
          day = calendar.day(Date.new(2017, 6, 8))
          day.celebrations[0].title.must_match /Ježíše Krista.+? kněze/
        end
      end
    end
  end
end
