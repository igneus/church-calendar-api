module ChurchCalendar
  class Celebration < Grape::Entity
    expose :title, :colour
    expose :rank
    expose :rank_num

    private

    def rank
      object.rank.short_desc || object.rank.desc
    end

    def rank_num
      object.rank.priority
    end

    def colour
      object.colour.to_sym
    end
  end
end
