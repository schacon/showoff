require_relative 'html_output'

module Parade
  module Commands

    #
    # Saves an html representation of the presentation to a single HTML file.
    #
    # @see HtmlOutput
    #
    class StaticHtml
      include RenderFromTemplate

      def description
        "Output into a single HTML file"
      end

      def generate(options)
        options.merge!('template' => 'print')

        html_generator = HtmlOutput.new
        html_content = html_generator.generate(options)

        output_file = options[:output] || default_html_output

        if create_file_with_contents output_file, html_content, options
          puts "Saved HTML to #{output_file}"
        end
      end

      def default_html_output
        "presentation.html"
      end

    end

  end
end
