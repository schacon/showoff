require_relative 'presentation_filepath_parser'

module Parade
  module Parsers

    class Dsl

      #
      # The parade DSL parse method is used to convert the parade file contents
      # into executable ruby code. This method is also called recursively when
      # a section contains sub-sections to properly parse that data as well.
      #
      # @param [String,Section] contents the string representation of the parade
      #   dsl contents to be parsed or the current section to be used as the
      #   current context.
      # @param [Hash] options additional options to provide additional
      #   configuration to the parsing process.
      #
      # def self.parse(contents,options = {})
      #   builder = new
      #   builder.options = options
      #
      #   config = Proc.new { eval(contents) }
      #   builder.instance_eval(&config)
      #
      #   builder.current_section
      # end

      def self.parse(contents,options = {},&config)
        builder = new
        builder.options = options

        if contents.is_a? Section
          builder.current_section = contents
        else
          config = Proc.new { eval(contents) }
        end

        builder.instance_eval(&config)

        builder.current_section
      end

      #
      # This is used within the DSL to set the title of the current section.
      #
      # @param [String] new_title the title for the setion.
      #
      def title(new_title)
        current_section.title = new_title
      end

      #
      # This is used within the DSL to set the description of the current section.
      #
      # @param [String] new_description the description for the setion.
      #
      def description(new_description)
        current_section.description = new_description
      end

      #
      # This is used by the DSL to add additional sections. Adds the specified
      # slides or sub-sections, defined by their filepaths, as a subsection of
      # this section.
      #
      def section(*filepaths,&block)

        if block
          sub_section = Section.new :title => filepaths.flatten.compact.join(" ")
          section_content = self.class.parse sub_section, options, &block
        else
          section_content = Array(filepaths).flatten.compact.map do |filepath|
            filepath = File.join(current_path,filepath)
            PresentationFilepathParser.parse(filepath,options)
          end
        end

        current_section.add_section section_content
        section_content
      end

      alias_method :slides, :section

      def template(template_name,template_file)
        current_section.add_template template_name, File.join(options[:current_path], template_file)
      end

      #
      # This is used by the DSL to specify any additional CSS Classes specific
      # to the section. All slides within the section will receive these
      # additional CSS Classes when the slide is rendered
      #
      # @example Specifying the css classes in multiple different ways
      #
      #     section "Iteration 0" do
      #       css_classes "blue-background"
      #       slides "iteration-zero.md"
      #     end
      #     section "Iteration 1" do
      #       css_classes [ "blue-background" ]
      #       slides "iteration-zero.md"
      #     end
      #     section "Iteration WonderWoman" do
      #       css_classes "blue-background", "red-font", "white-borders"
      #       slides "iteration-zero.md"
      #     end
      #     section "Iteration Spiderman" do
      #       css_classes "blue-background red-spandex web-spitters"
      #       slides "iteration-zero.md"
      #     end
      #
      def css_classes(*css_classes)
        current_section.css_classes = css_classes.flatten.map { |css_class| css_class.split(" ") }.flatten
      end

      #
      # This is used by the DSL to specify the resources used by the presentation
      #
      def resources(resource_filepath)
        current_section.add_resource File.join(options[:current_path], resource_filepath)
      end


      #
      # Sets the current sections theme to the specified theme
      # @note this will only work at the top level section of the presentation
      #
      def theme(theme_name)
        current_section.theme = theme_name
      end

      #
      # Sets the current sections footer to the specified template file
      # @note this will only work at the top level section of the presentation
      #
      def footer(footer_name)
        current_section.footer = File.join(options[:current_path], footer_name)
      end

      def pause_message(message)
        current_section.pause_message = message
      end

      # @return [Hash] configuration options that the DSL class will use
      #   and pass to other file and directory parsers to ensure the
      #   path information is presevered correctly.
      attr_accessor :options

      # @return [String] the root path where the presentation is being served
      #   from. This path is necessary to ensure that images have the correct
      #   image path built for it.
      def root_path
        File.directory?(options[:root_path]) ? options[:root_path] : File.dirname(options[:root_path])
      end

      # @return [String] the current path is the path for the current section
      #   this usually differs from the root_path when parsing sections defined
      #   within a section (a sub-section).
      def current_path
        if options[:current_path]
          File.directory?(options[:current_path]) ? options[:current_path] : File.dirname(options[:current_path])
        else
          root_path
        end
      end

      attr_writer :current_section

      # @return [Section] the current section being built.
      def current_section
        @current_section ||= begin
          new_section = Section.new
          new_section.add_resource current_path
          new_section
        end
      end

    end

  end
end