require_relative 'renderers/update_image_paths'

module Parade

  #
  # A Parade presentation is composed of a Section that may also be composed
  # of many slides and sub-sections (child sections) of slides.
  #
  class Section

    def initialize(params = {})
      @description = ""
      @post_renderers = []
      @sections = []

      @templates = {}
      params.each {|k,v| send("#{k}=",v) if respond_to? "#{k}=" }
    end

    # @param [String] title the new title of the section
    attr_writer :title

    # @return [String] the title of the section
    def title
      @title ? @title : (section ? section.title : "Section")
    end

    # @return [Array<String>] the name of all the parent sections. In this
    #   instance we are not interested in sections without names. These are
    #   the lowest level sections and are usually within a parent section that
    #   they are acurrately named.
    def hierarchy
      Array(@title) + (section ? section.hierarchy : [])
    end

    # @return [String] the description of the section
    attr_accessor :description

    # @return [Array<#slides>] returns an array of a Section objects or array
    #   of Slide objects.
    attr_reader :sections

    # @return [Section] the parent section of this section. nil if this is a
    #   root section.
    attr_accessor :section

    # Set the additional css classes that will be applied to all the slides
    # within the section.
    attr_writer :css_classes

    # @return [Array<String>] returns an array of css classes names
    def css_classes
      @css_classes || []
    end

    #
    # Append sections to this section.
    #
    # @param [Section,Array<Section>] content this any section that you want to
    #   add to this section.
    #
    def add_section(sub_sections)
      sub_sections = Array(sub_sections).compact.flatten.map do |sub_section|
        sub_section.section = self
        sub_section
      end
      @sections = @sections + sub_sections
      sub_sections
    end

    #
    # Append slides to this setion.
    #
    # @param [Slide,Array<Slide>] content this any section that you want to
    #   add to this section.
    #
    def add_slides(slides)
      sub_slides = Array(slides).compact.flatten.map do |slide|
        slide.section = self
        slide
      end

      @sections = @sections + sub_slides
      sub_slides
    end

    #
    # @example 'opening' would be the template name and 'custom_template.erb'
    #   would be the template filename.
    #
    #     section "Introduction" do
    #       template "opening", "custom_template.erb"
    #     end
    #
    # @param [String] template_name the name of the template which it is
    #   referred to by the slides.
    #
    # @param [Types] template_filepath the filepath to the template to be loaded
    #
    def add_template(template_name,template_filepath)
      @templates[template_name] = template_filepath
    end

    #
    # @param [String] template_name the name of the template
    # @param [Boolean] use_default_when_nil if while searching for the template
    #   it should use the parent section's default template. This usually wants
    #   to be false when looking for a specific template.
    #
    # @return [String] the filepath of the parent section template
    def parent_section_template(template_name,use_default_when_nil=true)
      section.template(template_name,use_default_when_nil) if section
    end

    #
    # @return [String] the filepath of the default slide template.
    def default_template
      File.join(File.dirname(__FILE__), "..", "views", "slide.erb")
    end

    #
    # Given the template name return the template file name associated with it.
    # When a template is not found with the name within the section, the section
    # traverses parent sections until it is found.
    #
    # A default template can be defined for a section which it will default
    # to when no template name has been specified or the template name could
    # not be found. Again the parent sections will be traversed if they have
    # a default template.
    #
    # When there is no template specified or found within then it will default
    # to the original slide template.
    #
    # @param [String] template_name the name of the template to retrieve.
    #
    # @return [String] the filepath to the template, given the template name.
    #
    def template(template_name,use_default_when_nil = true)
      template_for_name = @templates[template_name] || parent_section_template(template_name,false)
      template_for_name = (@templates['default'] || parent_section_template('default')) unless template_for_name and use_default_when_nil
      template_for_name || default_template
    end

    attr_writer :pause_message

    #
    # @return [String] the pause message for the section, if none has been
    #   specified the default pause message is returned.
    def pause_message
      @pause_message || default_pause_message
    end

    def default_pause_message
      ""
    end

    attr_writer :footer

    def footer
      footer_erb = ERB.new File.read(@footer || default_footer)
      footer_erb.result(binding)
    end

    def default_footer
      File.join(File.dirname(__FILE__), "..", "views", "footer.erb")
    end

    def resources
      @resources || []
    end

    def add_resource(resource_filepath)
      @resources ||= []
      @resources << resource_filepath
    end

    # Allows for the scene to have a theme defined for it.
    # @note this is only respected by the top-level scene in the presentation
    attr_accessor :theme

    # @return [Array<Slide>] the slides contained within this section and any
    #   sub-section.
    def slides
      sections_slides = sections.map do |section_or_slide|
        section_or_slide.slides
      end.flatten

      # Update the sequence on all the slides for the entire section.
      sections_slides.each_with_index {|slide,count| slide.sequence = (count + 1) }
    end

    # @return [Array<#render>] returns a list of Renderers that will perform
    #   their renderering on the slides after the slides have all habe been
    #   rendered.
    attr_reader :post_renderers

    #
    # @param [#render] renderer add a renderer, any object responding to
    #   #render, that will process the slides HTML content.
    #
    def add_post_renderer(renderer)
      @post_renderers << renderer
    end

    # @return [String] HTML representation of the section
    def to_html(options = {})
      slides.map do |section_or_slide|
        post_renderers.inject(section_or_slide.to_html) do |content,renderer|
          renderer.render(content,options)
        end
      end.join("\n")
    end

  end
end