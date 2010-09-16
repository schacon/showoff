require 'rubygems'
require 'sinatra/base'
require 'json'
require 'nokogiri'
require 'showoff_utils'
require 'princely'
require 'ftools'

begin
  require 'RMagick'
rescue LoadError
  puts 'image sizing disabled - install RMagick'
end

begin
  require 'princely'
rescue LoadError
  puts 'pdf generation disabled - install princely'
end

begin
  require 'rdiscount'
rescue LoadError
  require 'bluecloth'
  Markdown = BlueCloth
end
require 'pp'

class ShowOff < Sinatra::Application

  attr_reader :cached_image_size

  set :views, File.dirname(__FILE__) + '/../views'
  set :public, File.dirname(__FILE__) + '/../public'
  set :pres_dir, 'example'

  def initialize(app=nil)
    super(app)
    puts dir = File.expand_path(File.join(File.dirname(__FILE__), '..'))
    if Dir.pwd == dir
      options.pres_dir = dir + '/example'
      @root_path = "."
    else
      options.pres_dir = Dir.pwd
      @root_path = ".."
    end
    @cached_image_size = {}
    puts options.pres_dir
    @pres_name = options.pres_dir.split('/').pop
  end

  helpers do
    def load_section_files(section)
      section = File.join(options.pres_dir, section)
      files = Dir.glob("#{section}/**/*").sort
      pp files
      files
    end

    def css_files
      Dir.glob("#{options.pres_dir}/*.css").map { |path| File.basename(path) }
    end

    def js_files
      Dir.glob("#{options.pres_dir}/*.js").map { |path| File.basename(path) }
    end

    def preshow_files
      Dir.glob("#{options.pres_dir}/_preshow/*").map { |path| File.basename(path) }.to_json
    end

    def process_markdown(name, content, static=false)
      slides = content.split(/^!SLIDE/)
      slides.delete('')
      final = ''
      if slides.size > 1
        seq = 1
      end
      slides.each do |slide|
        md = ''
        # extract content classes
        lines = slide.split("\n")
        content_classes = lines.shift.split rescue []
        slide = lines.join("\n")
        # add content class too
        content_classes.unshift "content"
        # extract transition, defaulting to none
        transition = 'none'
        content_classes.delete_if { |x| x =~ /^transition=(.+)/ && transition = $1 }
        # extract id, defaulting to none
        id = nil
        content_classes.delete_if { |x| x =~ /^#([\w-]+)/ && id = $1 }
        puts "id: #{id}" if id
        puts "classes: #{content_classes.inspect}"
        puts "transition: #{transition}"
        # create html
        md += "<div"
        md += " id=\"#{id}\"" if id
        md += " class=\"slide\" data-transition=\"#{transition}\">"
        if seq
          md += "<div class=\"#{content_classes.join(' ')}\" ref=\"#{name}/#{seq.to_s}\">\n"
          seq += 1
        else
          md += "<div class=\"#{content_classes.join(' ')}\" ref=\"#{name}\">\n"
        end
        sl = Markdown.new(slide).to_html
        sl = update_image_paths(name, sl, static)
        md += sl
        md += "</div>\n"
        md += "</div>\n"
        final += update_commandline_code(md)
        final = update_p_classes(final)
      end
      final
    end

    # find any lines that start with a <p>.(something) and turn them into <p class="something">
    def update_p_classes(markdown)
      markdown.gsub(/<p>\.(.*?) /, '<p class="\1">')
    end

    def update_image_paths(path, slide, static=false)
      paths = path.split('/')
      paths.pop
      path = paths.join('/')
      replacement_prefix = static ?
        %(img src="file://#{options.pres_dir}/#{path}) :
        %(img src="/image/#{path})
      slide.gsub(/img src=\"(.*?)\"/) do |s|
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
          img = Magick::Image.ping(path).first
          cached_image_size[path] = [img.columns, img.rows]
        end
        cached_image_size[path]
      end
    else
      def get_image_size(path)
      end
    end

    def update_commandline_code(slide)
      html = Nokogiri::XML.parse(slide)

      html.css('pre').each do |pre|
        pre.css('code').each do |code|
          out = code.text
          lines = out.split("\n")
          if lines.first[0, 3] == '@@@'
            lang = lines.shift.gsub('@@@', '').strip
            pre.set_attribute('class', 'sh_' + lang)
            code.content = lines.join("\n")
          end
        end
      end

      html.css('.commandline > pre > code').each do |code|
        out = code.text
        lines = out.split(/^\$(.*?)$/)
        lines.delete('')
        code.content = ''
        while(lines.size > 0) do
          command = lines.shift
          result = lines.shift
          c = Nokogiri::XML::Node.new('code', html)
          c.set_attribute('class', 'command')
          c.content = '$' + command
          code << c
          c = Nokogiri::XML::Node.new('code', html)
          c.set_attribute('class', 'result')
          c.content = result
          code << c
        end
      end
      html.root.to_s
    end

    def get_slides_html(static=false)
      sections = ShowOffUtils.showoff_sections(options.pres_dir)
      files = []
      if sections
        sections.each do |section|
          files << load_section_files(section)
        end
        files = files.flatten
        files = files.select { |f| f =~ /.md/ }
        data = ''
        files.each do |f|
          fname = f.gsub(options.pres_dir + '/', '').gsub('.md', '')
          data += process_markdown(fname, File.read(f), static)
        end
      end
      data
    end

    def inline_css(csses, pre = nil)
      css_content = '<style type="text/css">'
      csses.each do |css_file|
        if pre
          css_file = File.join(File.dirname(__FILE__), '..', pre, css_file)
        else
          css_file = File.join(options.pres_dir, css_file)
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
          js_file = File.join(options.pres_dir, js_file)
        end
        js_content += File.read(js_file)
      end
      js_content += '</script>'
      js_content
    end

    def index(static=false)
      if static
        @slides = get_slides_html(static)
        @asset_path = "."
      end
      erb :index
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

      assets.join("\n")
    end

    def slides(static=false)
      get_slides_html(static)
    end

    def onepage(static=false)
      @slides = get_slides_html(static)
      erb :onepage
    end

    def pdf(static=false)
      @slides = get_slides_html(static)
      @no_js = true
      html = erb :onepage
      p = Princely.new
      # TODO make a random filename
      p.pdf_from_string_to_file(html, '/tmp/preso.pdf')
      File.new('/tmp/preso.pdf')
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
      data = showoff.send(what, true)
      if data.is_a?(File)
        File.cp(data.path, "#{name}.pdf")
      else
        out  = "#{path}/#{name}/static"
        # First make a directory
        File.makedirs("#{out}")

				# Next, copy static files
        File.makedirs("#{out}/files")

				# look for file references
				file_strings = data.scan(/\"(file:\/\/.*?)\"/)
				file_strings.each do |match|
					string = match[0]
					file = string.gsub('file://', '')  # Absolute Path to File
					rel_path = "files/#{File.basename(file)}"
					FileUtils.copy_entry(file, "#{out}/#{rel_path}") # copy static file
					p string
					data.gsub!(string, rel_path) # replace the file reference in the html
				end

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
      end
    end

  get %r{(?:image|file)/(.*)} do
    path = params[:captures].first
    full_path = File.join(options.pres_dir, path)
    send_file full_path
  end

  get %r{/(.*)} do
    @title = ShowOffUtils.showoff_title
    what = params[:captures].first
    what = 'index' if "" == what
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
