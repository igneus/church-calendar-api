module ChurchCalendar
  class Day < Grape::Entity
    expose :date
    expose :season
    expose :season_week
  end
end
