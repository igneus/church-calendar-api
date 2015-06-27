module ChurchCalendar
  class Day < Grape::Entity
    expose :date
    expose :season
    expose :season_week
    expose :celebrations, using: Celebration
    expose :weekday

    private

    WDAYS = %w{sunday monday tuesday wednesday thursday friday saturday}

    def weekday
      WDAYS[object.date.wday]
    end
  end
end
