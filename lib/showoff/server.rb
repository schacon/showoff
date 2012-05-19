require_relative "../showoff_utils"
require_relative "parsers/dsl"
require_relative 'renderers/update_image_paths'

require_relative 'features/live_ruby'
require_relative 'features/pdf_presentation'

module ShowOff

  class Server < Sinatra::Application

    set :views, File.dirname(__FILE__) + '/../views'
    set :public_folder, File.dirname(__FILE__) + '/../public'

    set :verbose, false
    set :presentation_directory, '.'
    set :pres_file, 'showoff'

    def presentation
      pres_filepath = File.join(settings.presentation_directory,settings.pres_file)
      contents = File.read pres_filepath
      root_section = Parsers::Dsl.parse contents, :root_path => pres_filepath

      root_section.add_post_renderer Renderers::UpdateImagePaths.new :root_path => File.dirname(pres_filepath)
      root_section
    end

    def initialize(app=nil)
      super(app)

      settings.presentation_directory ||= Dir.pwd
      settings.presentation_directory = File.expand_path(settings.presentation_directory)

      require_ruby_files

      @root_path = "."
      @pres_name = settings.presentation_directory.split('/').pop
      @asset_path = "./"
    end

    def self.pres_dir_current
      opt = {:pres_dir => Dir.pwd}
      ShowOff.set opt
    end

    def require_ruby_files
      Dir.glob("#{settings.presentation_directory}/*.rb").map { |path| require path }
    end

    helpers do

      def css_files
        Dir.glob("#{settings.presentation_directory}/*.css").map { |path| File.basename(path) }
      end

      def js_files
        Dir.glob("#{settings.presentation_directory}/*.js").map { |path| File.basename(path) }
      end

      def preshow_files
        Dir.glob("#{settings.presentation_directory}/_preshow/*").map { |path| File.basename(path) }.to_json
      end

      def inline_css(csses, pre = nil)
        css_content = '<style type="text/css">'
        csses.each do |css_file|
          if pre
            css_file = File.join(File.dirname(__FILE__), '..', pre, css_file)
          else
            css_file = File.join(settings.presentation_directory, css_file)
          end
          css_content += File.read(css_file)
        end
        css_content += '</style>'
        css_content
      end

      def inline_js(jses, pre = nil)
        js_content = '<script type="text/javascript">'
        jses.each do |js_file|
          if pre
            js_file = File.join(File.dirname(__FILE__), '..', pre, js_file)
          else
            js_file = File.join(settings.presentation_directory, js_file)
          end
          js_content += File.read(js_file)
        end
        js_content += '</script>'
        js_content
      end

      def index
        erb :index
      end

      def presenter
        erb :presenter
      end

      def slides
        presentation.to_html
      end

    end

    get %r{(?:image|file)/(.*)} do
      path = params[:captures].first
      full_path = File.join(settings.presentation_directory, path)
      send_file full_path
    end

    get %r{/(.*)} do
      @title = presentation.title
      what = params[:captures].first
      what = 'index' if "" == what
      @asset_path = (env['SCRIPT_NAME'] || '').gsub(/\/?$/, '/').gsub(/^\//, '')
      if (what != "favicon.ico")
        data = send(what)
        if data.is_a?(File)
          send_file data.path
        else
          data
        end
      end
    end

    def onepage
      @slides = presentation.to_html
      erb :onepage
    end

    include LiveRuby
    include PDFPresentation

  end

end
