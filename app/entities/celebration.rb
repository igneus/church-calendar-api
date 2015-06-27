module ChurchCalendar
  class Celebration < Grape::Entity
    expose :title, :colour
    expose :rank
    expose :rank_num

    private

    def rank
      object.rank.short_desc
    end

    def rank_num
      object.rank.priority
    end
  end
end
