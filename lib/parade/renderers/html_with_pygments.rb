require 'redcarpet'
require 'rouge'
require 'rouge/plugins/redcarpet'

module Parade
  module Renderers
    class HTMLwithPygments < Redcarpet::Render::XHTML
      include Rouge::Plugins::Redcarpet

      #
      # When rendering the markdown, the code should be rendered using the
      # Pygments highlight which corresponds to the ghf_marked.css
      #
      # Additionally a class `sh_javascript` or `sh_ruby` is added that will
      # assist in providing a system to provide live interactive elements
      # through the javascript defined in `parade.js`.
      #
      # @param [String] code the fenced code to be highlighted
      # @param [String] language the name of the fenced code
      #
      # def block_code(code, language)
      #   syntax_highlighted_html = Pygments.highlight code, :lexer => language,
      #     :options => {:encoding => 'utf-8'}

      #   syntax_highlighted_html.gsub('class="highlight"',"class=\"highlight sh_#{language}\"")
      # end

      def block_code(code, language)
        lexer = Rouge::Lexer.find_fancy(language, code) || Rouge::Lexers::Text

        # XXX HACK: Redcarpet strips hard tabs out of code blocks,
        # so we assume you're not using leading spaces that aren't tabs,
        # and just replace them here.
        if lexer.tag == 'make'
          code.gsub! /^    /, "\t"
        end

        formatter = Rouge::Formatters::HTML.new(
          :css_class => "highlight sh_#{lexer.tag}"
        )

        formatter.format(lexer.lex(code))
      end

      def self.render(content)
        markdown = Redcarpet::Markdown.new(Renderers::HTMLwithPygments,
          :fenced_code_blocks => true,
          :no_intra_emphasis => true,
          :autolink => true,
          :strikethrough => true,
          :lax_html_blocks => true,
          :superscript => true,
          :hard_wrap => true,
          :tables => true,
          :xhtml => true)
        markdown.render(content)
      end

    end
  end
end