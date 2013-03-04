require_relative 'renderers/html_with_rouge'

module Parade

  module SlidePreRenderers
    extend self

    def register(renderer)
      renderers.push renderer
    end

    def renderers
      @renderers ||= []
    end
  end

  SlidePreRenderers.register Renderers::HTMLWithRouge

end