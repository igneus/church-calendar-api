require 'scorched'
require 'haml'

module ChurchCalendar
  class Web < Scorched::Controller
    config << {
      static_dir: 'public'
    }
    render_defaults << {
      layout: :_layout,
      engine: :haml
    }

    get '/' do
      render :index
    end

    get '/browse' do
      render :browse, engine: :erb, layout: nil
    end

    get '/api-doc' do
      render :apidoc
    end

    get '/about' do
      render :about
    end
  end
end
