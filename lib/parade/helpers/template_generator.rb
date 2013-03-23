require 'ostruct'

module Parade

  #
  # TemplateGenator uses ERB to generate a template and uses itself as the
  # reference as the binding. This template generator is being used primarily
  # as a way to generate static versions of the content in HTML.
  #
  # When created an :erb_template_file needs to be specified in the Hash, all
  # other fields are dependent on what is contained within the template itself
  #
  class TemplateGenerator < OpenStruct

    #
    # @param [String] filepath the filepath to load
    #
    def css_template(filepath)
      CSSTemplateGenerator.new :filepath => filepath
    end

    def js_template(filepath)
      JSTemplateGenerator.new :filepath => filepath
    end

    #
    # Return javascript to be inlined in a template
    #
    # @param [String] filepath the filepath to the javascript file
    # @return [String] HTML content that is inlined javascript data
    def js(*filepaths)
      filepaths.map {|filepath| js_template(filepath).render }.join("\n")
    end

    #
    # Return stylesheet to be inlined in a template
    #
    # @param [String] filepath the filepath to the stylesheet file
    # @return [String] HTML content that is inlined stylesheet data
    #
    def css(*filepaths)
      filepaths.map {|filepath| css_template(filepath).render }.join("\n")
    end

    def custom_css_files
      if custom_asset_path
        Dir.glob("#{custom_asset_path}**/*.css").map do |path|
          css_template(path).render
        end.join("\n")
      end
    end

    #
    # This helper method is called within the header to return the theme specified
    # by the preseation
    #
    def theme_css
      css("themes/#{presentation.theme}.css") if presentation.theme
    end

    #
    # To provide support of having references to other templates, this will
    # handle erb method calls and in-line that template's content
    #
    # @param [Strign] filepath the filepath to another template
    # @return [String] HTML content of the specfied template at the filepath
    #
    def erb(filepath)
      template_filepath = File.join File.dirname(erb_template_file), "#{filepath}.erb"
      template_file = ERB.new File.read(template_filepath)
      template_file.result(binding)
    end

    #
    # @return [Types] the HTML content of the template specified
    #
    def render
      template_file = ERB.new File.read(erb_template_file)
      template_file.result(binding)
    end

  end

  #
  # Generate inline CSS assets. Using CssParser it is able to traverse imports
  # to ensure all CSS is inlined within the document.
  #
  # Also embeds all images contained within the CSS into the inlined CSS.
  #
  class CSSTemplateGenerator < TemplateGenerator
    include Helpers::EncodeImage

    def content
      content_filepath = File.exists?(filepath) ? filepath : File.join(File.dirname(__FILE__), "..", "..", "public", "css", filepath)
      parser = CssParser::Parser.new
      parser.load_file!(content_filepath)

      css_contents = parser.to_s

      css_contents.gsub(/url\([\s"']*([^\)"'\s]*)[\s"']*\)/m) do |image_uri|
        image_name = Regexp.last_match(1)
        image_path = File.join File.dirname(content_filepath), image_name
        base64_data = image_path_to_base64(image_path)
        "url(#{base64_data})"
      end

    end

    def erb_template_file
      File.join File.dirname(__FILE__), "..", "..", "views", "inline_css.erb"
    end

  end

  #
  # Inline the specified javascript
  #
  class JSTemplateGenerator < TemplateGenerator

    def content
      content_filepath = File.exists?(filepath) ? filepath : File.join(File.dirname(__FILE__), "..", "..", "public", "js", filepath)
      File.read content_filepath
    end

    def erb_template_file
      File.join File.dirname(__FILE__), "..", "..", "views", "inline_js.erb"
    end

  end

end