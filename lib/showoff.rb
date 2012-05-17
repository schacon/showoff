require 'rubygems'
require 'sinatra/base'
require 'json'
require 'nokogiri'
require 'fileutils'
require 'logger'

here = File.expand_path(File.dirname(__FILE__))
require "#{here}/showoff_utils"
require "#{here}/commandline_parser"

begin
  require 'RMagick'
rescue LoadError
  $stderr.puts 'WARN: image sizing disabled - install rmagick'
end

begin
  require 'pdfkit'
rescue LoadError
  $stderr.puts 'WARN: pdf generation disabled - install pdfkit'
end

require 'tilt'

class ShowOff < Sinatra::Application

  attr_reader :cached_image_size

  set :views, File.dirname(__FILE__) + '/../views'
  set :public_folder, File.dirname(__FILE__) + '/../public'

  set :verbose, false
  set :pres_dir, '.'
  set :pres_file, 'showoff.json'
  set :page_size, "Letter"
  set :pres_template, nil
  set :showoff_config, nil
  set :encoding, nil

  def initialize(app=nil)
    super(app)
    @logger = Logger.new(STDOUT)
    @logger.formatter = proc { |severity,datetime,progname,msg| "#{progname} #{msg}\n" }
    @logger.level = settings.verbose ? Logger::DEBUG : Logger::WARN

    dir = File.expand_path(File.join(File.dirname(__FILE__), '..'))
    @logger.debug(dir)

    showoff_dir = File.expand_path(File.join(File.dirname(__FILE__), '..'))
    settings.pres_dir ||= Dir.pwd
    @root_path = "."

    settings.pres_dir = File.expand_path(settings.pres_dir)
    if (settings.pres_file)
      ShowOffUtils.presentation_config_file = settings.pres_file
    end

    # Load configuration for page size and template from the
    # configuration JSON file
    if File.exists?(ShowOffUtils.presentation_config_file)
      showoff_json = JSON.parse(File.read(ShowOffUtils.presentation_config_file))
      settings.showoff_config = showoff_json
      
      # Set options for encoding, template and page size
      settings.encoding = showoff_json["encoding"]
      settings.page_size = showoff_json["page-size"] || "Letter"
      settings.pres_template = showoff_json["templates"] 
    end


    @logger.debug settings.pres_template

    @cached_image_size = {}
    @logger.debug settings.pres_dir
    @pres_name = settings.pres_dir.split('/').pop
    require_ruby_files

    # Default asset path
    @asset_path = "./"

    # Initialize Markdown Configuration
    #MarkdownConfig::setup(settings.pres_dir)
  end

  def self.pres_dir_current
    opt = {:pres_dir => Dir.pwd}
    ShowOff.set opt
  end

  def require_ruby_files
    Dir.glob("#{settings.pres_dir}/*.rb").map { |path| require path }
  end

  helpers do
    def load_section_files(section)
      section = File.join(settings.pres_dir, section)
      files = if File.directory? section
        Dir.glob("#{section}/**/*").sort
      else
        [section]
      end
      @logger.debug files
      files
    end

    def css_files
      Dir.glob("#{settings.pres_dir}/*.css").map { |path| File.basename(path) }
    end

    def js_files
      Dir.glob("#{settings.pres_dir}/*.js").map { |path| File.basename(path) }
    end


    def preshow_files
      Dir.glob("#{settings.pres_dir}/_preshow/*").map { |path| File.basename(path) }.to_json
    end

    # todo: move more behavior into this class
    class Slide
      attr_reader :classes, :text, :tpl
      def initialize( context = "")

        @tpl = "default"
        @classes = ["content"]

        # Parse the context string for options and content classes
        if context and context.match(/(\[(.*?)\])?(.*)/)

          options = ShowOffUtils.parse_options($2)
          @tpl = options["tpl"] if options["tpl"]
          @classes += $3.strip.chomp('>').split if $3

        end

        @text = ""
      end
      def <<(s)
        @text << s
        @text << "\n"
      end
      def empty?
        @text.strip == ""
      end
    end


    def process_markdown(name, content, static=false, pdf=false)
      if settings.encoding and content.respond_to?(:force_encoding)
        content.force_encoding(settings.encoding)
      end

      # if there are no !SLIDE markers, then make every H1 define a new slide
      unless content =~ /^\<?!SLIDE/m
        content = content.gsub(/^# /m, "<!SLIDE>\n# ")
      end

      # todo: unit test
      lines = content.split("\n")
      @logger.debug "#{name}: #{lines.length} lines"
      slides = []
      slides << (slide = Slide.new)
      until lines.empty?
        line = lines.shift
        if line =~ /^<?!SLIDE(.*)>?/
          ctx = $1 ? $1.strip : $1
          slides << (slide = Slide.new(ctx))
        else
          slide << line
        end
      end

      slides.delete_if {|slide| slide.empty? }

      final = ''
      if slides.size > 1
        seq = 1
      end
      slides.each do |slide|
        @slide_count += 1
        md = ''
        content_classes = slide.classes

        # extract transition, defaulting to none
        transition = 'none'
        content_classes.delete_if { |x| x =~ /^transition=(.+)/ && transition = $1 }
        # extract id, defaulting to none
        id = nil
        content_classes.delete_if { |x| x =~ /^#([\w-]+)/ && id = $1 }
        @logger.debug "id: #{id}" if id
        @logger.debug "classes: #{content_classes.inspect}"
        @logger.debug "transition: #{transition}"
        @logger.debug "tpl: #{slide.tpl} " if slide.tpl
        # create html
        md += "<div"
        md += " id=\"#{id}\"" if id
        md += " class=\"slide\" data-transition=\"#{transition}\">"


        template = "~~~CONTENT~~~"
        # Template handling
        if settings.pres_template
          # We allow specifying a new template even when default is
          # not given.
          if settings.pres_template.include?(slide.tpl) and
              File.exists?(settings.pres_template[slide.tpl])
            template = File.open(settings.pres_template[slide.tpl], "r").read()
          end
        end

        # Extract the content of the slide
        content = ""
        if seq
          content += "<div class=\"#{content_classes.join(' ')}\" ref=\"#{name}/#{seq.to_s}\">\n"
        else
          content += "<div class=\"#{content_classes.join(' ')}\" ref=\"#{name}\">\n"
        end
        sl = Tilt[:markdown].new { slide.text }.render
        sl = update_image_paths(name, sl, static, pdf)
        content += sl
        content += "</div>\n"

        # Apply the template to the slide and replace the key with
        # content of the slide
        md += process_content_for_replacements(template.gsub(/~~~CONTENT~~~/, content), @slide_count)

        # Apply other configuration

        md += "</div>\n"
        final += update_commandline_code(md)
        final = update_p_classes(final)

        if seq
          seq += 1
        end
      end
      final
    end

    # This method processes the content of the slide and replaces
    # content markers with their actual value information
    def process_content_for_replacements(content, seq)
      result = content.gsub("~~~CURRENT_SLIDE~~~", seq.to_s)
      # Now check for any kind of options
      content.scan(/(~~~CONFIG:(.*?)~~~)/).each do |match|
        result.gsub!(match[0], settings.showoff_config[match[1]]) if settings.showoff_config.key?(match[1])
      end

      result
    end

    def process_content_for_all_slides(content, num_slides)
      content.gsub("~~~NUM_SLIDES~~~", num_slides.to_s)
    end
    

    # find any lines that start with a <p>.(something) and turn them into <p class="something">
    def update_p_classes(markdown)
      markdown.gsub(/<p>\.(.*?) /, '<p class="\1">')
    end

    def update_image_paths(path, slide, static=false, pdf=false)
      paths = path.split('/')
      paths.pop
      path = paths.join('/')
      replacement_prefix = static ?
        ( pdf ? %(img src="file://#{settings.pres_dir}/#{path}) : %(img src="./file/#{path}) ) :
        %(img src="#{@asset_path}image/#{path})
      slide.gsub(/img src=[\"\'](?!https?:\/\/)([^\/].*?)[\"\']/) do |s|
        img_path = File.join(path, $1)
        w, h     = get_image_size(img_path)
        src      = %(#{replacement_prefix}/#{$1}")
        if w && h
          src << %( width="#{w}" height="#{h}")
        end
        src
      end
    end

    if defined?(Magick)
      def get_image_size(path)
        if !cached_image_size.key?(path)
          img = Magick::Image.ping(File.join(".", @asset_path, path)).first
          # don't set a size for svgs so they can expand to fit their container
          if img.mime_type == 'image/svg+xml'
            cached_image_size[path] = [nil, nil]
          else
            cached_image_size[path] = [img.columns, img.rows]
          end
        end
        cached_image_size[path]
      end
    else
      def get_image_size(path)
      end
    end

    def update_commandline_code(slide)
      html = Nokogiri::XML.parse(slide)
      parser = CommandlineParser.new

      html.css('pre').each do |pre|
        pre.css('code').each do |code|
          out = code.text
          lines = out.split("\n")
          if lines.first.strip[0, 3] == '@@@'
            lang = lines.shift.gsub('@@@', '').strip
            pre.set_attribute('class', 'sh_' + lang.downcase) if !lang.empty?
            code.content = lines.join("\n")
          end
        end
      end

      html.css('.commandline > pre > code').each do |code|
        out = code.text
        code.content = ''
        tree = parser.parse(out)
        transform = Parslet::Transform.new do
          rule(:prompt => simple(:prompt), :input => simple(:input), :output => simple(:output)) do
            command = Nokogiri::XML::Node.new('code', html)
            command.set_attribute('class', 'command')
            command.content = "#{prompt} #{input}"
            code << command

            # Add newline after the input so that users can
            # advance faster than the typewriter effect
            # and still keep inputs on separate lines.
            code << "\n"

            unless output.to_s.empty?

              result = Nokogiri::XML::Node.new('code', html)
              result.set_attribute('class', 'result')
              result.content = output
              code << result
            end
          end
        end
        transform.apply(tree)
      end
      html.root.to_s
    end

    def get_slides_html(static=false, pdf=false)
      @slide_count = 0
      sections = ShowOffUtils.showoff_sections(settings.pres_dir, @logger)
      files = []
      if sections
        data = ''
        sections.each do |section|
          if section =~ /^#/
            name = section.each_line.first.gsub(/^#*/,'').strip
            data << process_markdown(name, "<!SLIDE subsection>\n" + section, static, pdf)
          else
            files = []
            files << load_section_files(section)
            files = files.flatten
            files = files.select { |f| f =~ /.md$/ }
            files.each do |f|
              fname = f.gsub(settings.pres_dir + '/', '').gsub('.md', '')
              data << process_markdown(fname, File.read(f), static, pdf)
            end
          end
        end
      end
      process_content_for_all_slides(data, @slide_count)
    end

    def inline_css(csses, pre = nil)
      css_content = '<style type="text/css">'
      csses.each do |css_file|
        if pre
          css_file = File.join(File.dirname(__FILE__), '..', pre, css_file)
        else
          css_file = File.join(settings.pres_dir, css_file)
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
          js_file = File.join(settings.pres_dir, js_file)
        end

        begin
          js_content += File.read(js_file)
        rescue Errno::ENOENT
          $stderr.puts "WARN: Failed to inline JS. No such file: #{js_file}"
          next
        end
      end
      js_content += '</script>'
      js_content
    end

    def inline_all_js(jses_directory)
       inline_js(Dir.entries(File.join(File.dirname(__FILE__), '..', jses_directory)).find_all{|filename| filename.length > 2 }, jses_directory)
    end

    def index(static=false)
      if static
        @title = ShowOffUtils.showoff_title
        @slides = get_slides_html(static)

        @pause_msg = ShowOffUtils.pause_msg

        # Identify which languages to bundle for highlighting
        @languages = @slides.scan(/<pre class=".*(?!sh_sourceCode)(sh_[\w-]+).*"/).uniq.map{ |w| "sh_lang/#{w[0]}.min.js"}

        @asset_path = "./"
      end
      erb :index
    end

    def presenter
      erb :presenter
    end

    def clean_link(href)
      if href && href[0, 1] == '/'
        href = href[1, href.size]
      end
      href
    end

    def assets_needed
      assets = ["index", "slides"]

      index = erb :index
      html = Nokogiri::XML.parse(index)
      html.css('head link').each do |link|
        href = clean_link(link['href'])
        assets << href if href
      end
      html.css('head script').each do |link|
        href = clean_link(link['src'])
        assets << href if href
      end

      slides = get_slides_html
      html = Nokogiri::XML.parse("<slides>" + slides + "</slides>")
      html.css('img').each do |link|
        href = clean_link(link['src'])
        assets << href if href
      end

      css = Dir.glob("#{settings.public_folder}/**/*.css").map { |path| path.gsub(settings.public_folder + '/', '') }
      assets << css

      js = Dir.glob("#{settings.public_folder}/**/*.js").map { |path| path.gsub(settings.public_folder + '/', '') }
      assets << js

      assets.uniq.join("\n")
    end

    def slides(static=false)
      get_slides_html(static)
    end

    def onepage(static=false)
      @slides = get_slides_html(static)
      @languages = @slides.scan(/<pre class=".*(?!sh_sourceCode)(sh_[\w-]+).*"/).uniq.map{ |w| "/sh_lang/#{w[0]}.min.js"}
      erb :onepage
    end

    def pdf(static=true)
      @slides = get_slides_html(static, true)
      @inline = true

      # Identify which languages to bundle for highlighting
      @languages = @slides.scan(/<pre class=".*(?!sh_sourceCode)(sh_[\w-]+).*"/).uniq.map{ |w| "/sh_lang/#{w[0]}.min.js"}

      html = erb :onepage
      # TODO make a random filename

      # Process inline css and js for included images
      # The css uses relative paths for images and we prepend the file url
      html.gsub!(/url\([\"\']?(?!https?:\/\/)(.*?)[\"\']?\)/) do |s|
        "url(file://#{settings.pres_dir}/#{$1})"
      end

      # Todo fix javascript path

      # PDFKit.new takes the HTML and any options for wkhtmltopdf
      # run `wkhtmltopdf --extended-help` for a full list of options
      kit = PDFKit.new(html, ShowOffUtils.showoff_pdf_options(settings.pres_dir))

      # Save the PDF to a file
      file = kit.to_file('/tmp/preso.pdf')
    end

  end


   def self.do_static(what)
      what = "index" if !what

      # Nasty hack to get the actual ShowOff module
      showoff = ShowOff.new
      while !showoff.is_a?(ShowOff)
        showoff = showoff.instance_variable_get(:@app)
      end
      name = showoff.instance_variable_get(:@pres_name)
      path = showoff.instance_variable_get(:@root_path)
      logger = showoff.instance_variable_get(:@logger)
      data = showoff.send(what, true)

      if data.is_a?(File)
        FileUtils.cp(data.path, "#{name}.pdf")
      else
        out = File.expand_path("#{path}/static")
        # First make a directory
        FileUtils.makedirs(out)
        # Then write the html
        file = File.new("#{out}/index.html", "w")
        file.puts(data)
        file.close
        # Now copy all the js and css
        my_path = File.join( File.dirname(__FILE__), '..', 'public')
        ["js", "css"].each { |dir|
          FileUtils.copy_entry("#{my_path}/#{dir}", "#{out}/#{dir}")
        }
        # And copy the directory
        Dir.glob("#{my_path}/#{name}/*").each { |subpath|
          base = File.basename(subpath)
          next if "static" == base
          next unless File.directory?(subpath) || base.match(/\.(css|js)$/)
          FileUtils.copy_entry(subpath, "#{out}/#{base}")
        }

        # Set up file dir
        file_dir = File.join(out, 'file')
        FileUtils.makedirs(file_dir)
        pres_dir = showoff.settings.pres_dir

        # ..., copy all user-defined styles and javascript files
        Dir.glob("#{pres_dir}/*.{css,js}").each { |path|
          FileUtils.copy(path, File.join(file_dir, File.basename(path)))
        }

        # ... and copy all needed image files
        data.scan(/img src=[\"\'].\/file\/(.*?)[\"\']/).flatten.each do |path|
          dir = File.dirname(path)
          FileUtils.makedirs(File.join(file_dir, dir))
          FileUtils.copy(File.join(pres_dir, path), File.join(file_dir, path))
        end
        # copy images from css too
        Dir.glob("#{pres_dir}/*.css").each do |css_path|
          File.open(css_path) do |file|
            data = file.read
            data.scan(/url\([\"\']?(?!https?:\/\/)(.*?)[\"\']?\)/).flatten.each do |path|
              path.gsub!(/(\#.*)$/, '') # get rid of the anchor
              path.gsub!(/(\?.*)$/, '') # get rid of the query
              logger.debug path
              dir = File.dirname(path)
              FileUtils.makedirs(File.join(file_dir, dir))
              FileUtils.copy(File.join(pres_dir, path), File.join(file_dir, path))
            end
          end
        end
      end
    end

   def eval_ruby code
     eval(code).to_s
   rescue => e
     e.message
   end

  get '/eval_ruby' do
    return eval_ruby(params[:code]) if ENV['SHOWOFF_EVAL_RUBY']

    return "Ruby Evaluation is off. To turn it on set ENV['SHOWOFF_EVAL_RUBY']"
  end

  get %r{(?:image|file)/(.*)} do
    path = params[:captures].first
    full_path = File.join(settings.pres_dir, path)
    send_file full_path
  end

  get %r{/(.*)} do
    @title = ShowOffUtils.showoff_title
    @pause_msg = ShowOffUtils.pause_msg
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
end
