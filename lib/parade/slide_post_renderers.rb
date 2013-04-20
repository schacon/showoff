require_relative 'renderers/command_line_renderer'
require_relative 'renderers/special_paragraph_renderer'
require_relative 'renderers/columns_renderer'
require_relative 'renderers/content_with_caption_renderer'

module Parade

  module SlidePostRenderers
    extend self

    def register(renderer)
      renderers.push renderer
    end

    def renderers
      @renderers ||= []
    end
  end

  SlidePostRenderers.register Renderers::SpecialParagraphRenderer
  SlidePostRenderers.register Renderers::CommandLineRenderer
  SlidePostRenderers.register Renderers::ColumnsRenderer.new(css_class: 'columns',
    html_element: "h2", segments: 12)
  SlidePostRenderers.register Renderers::ColumnsRenderer.new(css_class: 'comparison',
    html_element: "h2", segments: 12)
  SlidePostRenderers.register Renderers::ContentWithCaptionRenderer.new(css_class: 'content-with-caption',
  html_element: "h2")

end