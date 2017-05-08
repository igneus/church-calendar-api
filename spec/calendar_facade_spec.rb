require_relative 'spec_helper'

describe ChurchCalendar::CalendarFacade do
  before do
    @facade = ChurchCalendar.calendars['default']
  end

  describe '#day' do
    it 'survives February 29th on a leap year' do
      @facade.day Date.new(2000, 2, 29)
    end
  end

  describe '#month' do
    it 'survives February of a leap year' do
      @facade.days_of_month 2000, 2
    end
  end

  describe '#year' do
    it 'returns a Calendar' do
      c = @facade.year 2000

      c.must_be_kind_of CalendariumRomanum::Calendar
      c.year.must_equal 2000
    end
  end

  describe '#metadata' do
    it 'is a Hash' do
      md = @facade.metadata
      md.must_be_kind_of Hash
      md.wont_be :empty?
    end
  end
end
