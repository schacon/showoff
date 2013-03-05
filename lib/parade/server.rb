require_relative 'section'
require_relative "parsers/dsl"
require_relative 'renderers/update_image_paths'

require_relative 'features/pdf_presentation'
require_relative 'features/preshow'

require_relative 'slide_post_renderers'
require_relative 'slide_pre_renderers'

module Parade

  class Server < Sinatra::Application

    #
    # Includes the specified module into the server to grant the server additional
    # functionality.
    #
    def self.register(server_module)
      include server_module
    end

    #
    # Register a javascript file that will be loaded after the code javscript
    #
    def self.register_javascript(js_file)
      plugin_javascript_files.push js_file
    end

    #
    # @return the javascript files that have been registered by plugins
    #
    def self.plugin_javascript_files
      @javscript_files ||= []
    end


    def initialize(app=nil)
      super(app)
      require_ruby_files
    end

    def require_ruby_files
      Dir.glob("#{settings.presentation_directory}/*.rb").map { |path| require path }
    end

    set :views, File.dirname(__FILE__) + '/../views'
    set :public_folder, File.dirname(__FILE__) + '/../public'

    set :verbose, false

    set :presentation_directory do
      File.expand_path Dir.pwd
    end

    set :presentation_file, 'parade'

    set :default_presentation_files, [ 'parade', 'parade.json' ]

    def presentation_files
      (Array(settings.presentation_file) + settings.default_presentation_files).compact.uniq
    end

    def load_presentation
      root_node = Parsers::PresentationDirectoryParser.parse settings.presentation_directory,
        :root_path => settings.presentation_directory, :parade_file => presentation_files

      root_node.add_post_renderer Renderers::UpdateImagePaths.new :root_path => settings.presentation_directory
      root_node
    end

    helpers do

      #
      # A shortcut to define a CSS resource file within a view template
      #
      def css(filepath)
        %{<link rel="stylesheet" href="#{File.join "css", filepath}" type="text/css"/>}
      end

      #
      # A shortcut to define a Javascript resource file within a view template
      #
      def js(filepath)
        %{<script type="text/javascript" src="#{File.join "js", filepath}"></script>}
      end

      def custom_resource(resource_extension)
        load_presentation.resources.map do |resource_path|
          Dir.glob("#{resource_path}/*.#{resource_extension}").map do |path|
            relative_path = path.sub(settings.presentation_directory,'')
            yield relative_path if block_given?
          end.join("\n")
        end.join("\n")
      end

      #
      # Create resources links to all the CSS files found at the root of
      # presentation directory.
      #
      def custom_css_files
        custom_resource "css" do |path|
          css path
        end
      end

      def plugin_js_files
        self.class.plugin_javascript_files.map do |path|
          "<script type='text/javascript'>#{File.read(path)}</script>"
        end.join("\n")
      end

      #
      # Create resources links to all the Javascript files found at the root of
      # presentation directory.
      #
      def custom_js_files
        custom_resource "js" do |path|
          js path
        end
      end

      def presentation
        load_presentation
      end

      def title
        presentation.title
      end

      def slides
        presentation.to_html
      end

      def pause_message
        presentation.pause_message
      end
    end

    #
    # Path requests for files that match the prefix will be returned.
    #
    get %r{(?:image|file|js|css)/(.*)} do
      path = params[:captures].first
      full_path = File.join(settings.presentation_directory, path)
      send_file full_path
    end

    #
    # The request for slides is used by the client-side javascript presentation
    # and returns all the slides HTML.
    #
    get "/slides" do
      slides
    end

    get "/" do
      erb :index
    end

    get "/onepage" do
      erb :onepage
    end

    include PDFPresentation
    include Preshow

  end

end