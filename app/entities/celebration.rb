module ChurchCalendar
  class Celebration < Grape::Entity
    expose :title, :colour
    expose :rank
    expose :rank_num

    expose :text, if: lambda { |status, options| options[:compose_text] }

    private

    def rank
      object.rank.short_desc
    end

    def rank_num
      object.rank.priority
    end

    def text
      'fake text'
    end
  end
end
