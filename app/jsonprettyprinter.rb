module ChurchCalendar

  # Formats objects as indented JSON.
  # Usable as output formatter for Grape
  module JSONPrettyPrinter
    extend self

    def call(obj, env)
      j = obj.to_json
      unless json_parseable? j
        return j
      else
        return JSON.pretty_generate(JSON.parse(j))
      end
    end

    def json_parseable?(str)
      str =~ /^[\[\{]/
    end
  end
end
