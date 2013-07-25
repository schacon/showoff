require_relative '../renderers/inline_images'

module Parade
  module Commands

    #
    # HtmlOuput creates an HTML representation of the presentation and returns
    # it from the generate method. This is to be consumed by other commands
    # that my use this output to be saved or manipulated.
    #
    # @see StaticHtml
    # @see StaticPdf
    #
    class HtmlOutput
      include RenderFromTemplate

      def description
        "This method returns HTML output"
      end

      def generate(options)
        filepath = options['filepath']

        return unless File.exists? filepath

        if File.directory? filepath
          root_path = filepath
          root_node = Parsers::PresentationDirectoryParser.parse filepath, :root_path => ".",
            :parade_file => (Array(options['parade_file']) + [ "parade" ]).compact.uniq
        else
          root_path = File.dirname filepath
          root_node = Parsers::PresentationFileParser.parse filepath, :root_path => root_path
        end

        root_node.add_post_renderer Renderers::InlineImages

        template_options = {  'erb_template_file' => File.join(default_view_path, "#{options['template']}.erb"),
                              'custom_asset_path' => root_path,
                              'presentation' => root_node,
                              'slides' => root_node.to_html }

        render_template template_options
      end

    end

  end
end