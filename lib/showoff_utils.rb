class ShowOffUtils

  # Helper method to parse a comma separated options string and stores
  # the result in a dictionrary
  #
  # Example:
  # 
  #    "tpl=hpi,title=Over the rainbow"
  #
  #    will be stored as
  #
  #      { "tpl" => "hpi", "title" => "Over the rainbow" }
  def self.parse_options(option_string="")
    result = {}

    if option_string 
      option_string.split(",").each do |element|
        pair = element.split("=")
        result[pair[0]] = pair.size > 1 ? pair[1] : nil
      end
    end

    result
  end

  def self.presentation_config_file
    @presentation_config_file ||= 'showoff.json'
  end

  def self.presentation_config_file=(filename)
    @presentation_config_file = filename
  end

  def self.create(dirname,create_samples,dir='one')
    Dir.mkdir(dirname) if !File.exists?(dirname)
    Dir.chdir(dirname) do
      if create_samples
        # create section
        Dir.mkdir(dir)

        # create markdown file
        File.open("#{dir}/01_slide.md", 'w+') do |f|
          f.puts make_slide("My Presentation")
          f.puts make_slide("Bullet Points","bullets incremental",["first point","second point","third point"])
        end
      end

      # create showoff.json
      File.open(ShowOffUtils.presentation_config_file, 'w+') do |f|
        f.puts "{ \"name\": \"My Preso\", \"sections\": [ {\"section\":\"#{dir}\"} ]}"
      end
    end
  end

  HEROKU_GEMS_FILE = '.gems'
  HEROKU_BUNDLER_GEMS_FILE = 'Gemfile'
  HEROKU_CONFIG_FILE = 'config.ru'

	# Setup presentation to run on Heroku
  #
  # name         - String containing heroku name
  # force        - boolean if .gems/Gemfile and config.ru should be overwritten if they don't exist
  # password     - String containing password to protect your heroku site; nil means no password protection
  # use_dot_gems - boolean that, if true, indicates we should use the old, deprecated .gems file instead of Bundler
  def self.heroku(name, force = false, password = nil, use_dot_gems = false)
    modified_something = false

    if use_dot_gems
      modified_something = create_gems_file(HEROKU_GEMS_FILE,
                                            !password.nil?,
                                            force,
                                            lambda{ |gem| gem })
    else
      modified_something = create_gems_file(HEROKU_BUNDLER_GEMS_FILE,
                                            !password.nil?,
                                            force,
                                            lambda{ |gem| "gem '#{gem}'" },
                                            lambda{ "source :rubygems" })
    end

    create_file_if_needed(HEROKU_CONFIG_FILE,force) do |file|
      modified_something = true
      file.puts 'require "showoff"'
      if password.nil?
        file.puts 'run ShowOff.new'
      else
        file.puts 'require "rack"'
        file.puts 'showoff_app = ShowOff.new'
        file.puts 'protected_showoff = Rack::Auth::Basic.new(showoff_app) do |username, password|'
        file.puts	"\tpassword == '#{password}'"
        file.puts 'end'
        file.puts 'run protected_showoff'
      end
    end

    modified_something
  end

  # generate a static version of the site into the gh-pages branch
  def self.github
    ShowOff.do_static(nil)
    `git add static`
    sha = `git write-tree`.chomp
    tree_sha = `git rev-parse #{sha}:static`.chomp
    `git read-tree HEAD`  # reset staging to last-commit
    ghp_sha = `git rev-parse gh-pages 2>/dev/null`.chomp
    extra = ghp_sha != 'gh-pages' ? "-p #{ghp_sha}" : ''
    commit_sha = `echo 'static presentation' | git commit-tree #{tree_sha} #{extra}`.chomp
    `git update-ref refs/heads/gh-pages #{commit_sha}`
  end

  # Makes a slide as a string.
  # [title] title of the slide
  # [classes] any "classes" to include, such as 'smaller', 'transition', etc.
  # [content] slide content.  Currently, if this is an array, it will make a bullet list.  Otherwise
  #           the string value of this will be put in the slide as-is
  def self.make_slide(title,classes="",content=nil)
    slide = "!SLIDE #{classes}\n"
    slide << "# #{title} #\n"
    slide << "\n"
    if content
      if content.kind_of? Array
        content.each { |x| slide << "* #{x.to_s}\n" }
      else
        slide << content.to_s
      end
    end
    slide
  end

  TYPES = {
    :default => lambda { |t,size,source,type| make_slide(t,"#{size} #{type}",source) },
    'title' => lambda { |t,size,dontcare| make_slide(t,size) },
    'bullets' => lambda { |t,size,dontcare| make_slide(t,"#{size} bullets incremental",["bullets","go","here"])},
    'smbullets' => lambda { |t,size,dontcare| make_slide(t,"#{size} smbullets incremental",["bullets","go","here","and","here"])},
    'code' => lambda { |t,size,src| make_slide(t,size,blank?(src) ? "    @@@ Ruby\n    code_here()" : src) },
    'commandline' => lambda { |t,size,dontcare| make_slide(t,"#{size} commandline","    $ command here\n    output here")},
    'full-page' => lambda { |t,size,dontcare| make_slide(t,"#{size} full-page","![Image Description](image/ref.png)")},
  }


  # Adds a new slide to a given dir, giving it a number such that it falls after all slides
  # in that dir.
  # Options are:
  # [:dir] - dir where we put the slide (if omitted, slide is output to $stdout)
  # [:name] - name of the file, without the number prefix. (if omitted, a default is used)
  # [:title] - title in the slide.  If not specified the source file name is
  #            used.  If THAT is not specified, uses the value of +:name+.  If THAT is not
  #            specified, a suitable default is used
  # [:code] - path to a source file to use as content (force :type to be 'code')
  # [:number] - true if numbering should be done, false if not
  # [:type] - the type of slide to create
  def self.add_slide(options)

    add_new_dir(options[:dir]) if options[:dir] && !File.exists?(options[:dir])

    options[:type] = 'code' if options[:code]

    title = determine_title(options[:title],options[:name],options[:code])

    options[:name] = 'new_slide' if !options[:name]

    size,source = determine_size_and_source(options[:code])
    type = options[:type] || :default
    slide = TYPES[type].call(title,size,source)

    if options[:dir]
      filename = determine_filename(options[:dir],options[:name],options[:number])
      write_file(filename,slide)
    else
      puts slide
      puts
    end

  end

  # Adds the given directory to this presentation, appending it to
  # the end of showoff.json as well
  def self.add_new_dir(dir)
    puts "Creating #{dir}..."
    Dir.mkdir dir

    showoff_json = JSON.parse(File.read(ShowOffUtils.presentation_config_file))
    showoff_json["section"] = dir
    File.open(ShowOffUtils.presentation_config_file,'w') do |file|
      file.puts JSON.generate(showoff_json)
    end
    puts "#{ShowOffUtils.presentation_config_file} updated"
  end

  def self.blank?(string)
    string.nil? || string.strip.length == 0
  end

  def self.determine_size_and_source(code)
    size = ""
    source = ""
    if code
      source,lines,width = read_code(code)
      size = adjust_size(lines,width)
    end
    [size,source]
  end

  def self.write_file(filename,slide)
    File.open(filename,'w') do |file|
      file.puts slide
    end
    puts "Wrote #{filename}"
  end

  def self.determine_filename(slide_dir,slide_name,number)
    filename = "#{slide_dir}/#{slide_name}.md"
    if number
      max = find_next_number(slide_dir)
      filename = "#{slide_dir}/#{max}_#{slide_name}.md"
    end
    filename
  end

  # Finds the next number in the given dir to
  # name a slide as the last slide in the dir.
  def self.find_next_number(slide_dir)
    max = 0
    Dir.open(slide_dir).each do |file|
      if file =~ /(\d+).*\.md/
        num = $1.to_i
        max = num if num > max
      end
    end
    max += 1
    max = "0#{max}" if max < 10
    max
  end

  def self.determine_title(title,slide_name,code)
    if blank?(title)
      title = slide_name
      title = File.basename(code) if code
    end
    title = "Title here" if blank?(title)
    title
  end

  # Determines a more optimal value for the size (e.g. small vs. smaller)
  # based upon the size of the code being formatted.
  def self.adjust_size(lines,width)
    size = ""
    # These values determined empircally
    size = "small" if width > 50
    size = "small" if lines > 15
    size = "smaller" if width > 57
    size = "smaller" if lines > 19
    puts "warning, some lines are too long and the code may be cut off" if width > 65
    puts "warning, your code is too long and the code may be cut off" if lines > 23
    size
  end

  # Reads the code from the source file, returning
  # the code, indented for markdown, as well as the number of lines
  # and the width of the largest line
  def self.read_code(source_file)
    code = "    @@@ #{lang(source_file)}\n"
    lines = 0
    width = 0
    File.open(source_file) do |code_file|
      code_file.readlines.each do |line|
        code += "    #{line}"
        lines += 1
        width = line.length if line.length > width
      end
    end
    [code,lines,width]
  end

  def self.showoff_sections(dir,logger)
    index = File.join(dir, ShowOffUtils.presentation_config_file)
    sections = nil
    if File.exists?(index)
      data = JSON.parse(File.read(index))
      logger.debug data
      if data.is_a?(Hash)
        sections = data['sections']
      else
        sections = data
      end
      sections = sections.map do |s|
        if s.is_a? Hash
          s['section']
        else
          s
        end
      end
    else
      sections = ["."] # if there's no showoff.json file, make a boring one
    end
    sections
  end

  def self.showoff_title(dir = '.')
    get_config_option(dir, 'name', "Presentation")
  end

  def self.pause_msg(dir = '.')
    get_config_option(dir, 'pause_msg', '')
  end

  def self.showoff_pdf_options(dir = '.')
    opts = get_config_option(dir, 'pdf_options', {:page_size => 'Letter', :orientation => 'Landscape'})
    Hash[opts.map {|k, v| [k.to_sym, v]}] # keys must be symbols
  end

  def self.showoff_markdown(dir = ".")
    get_config_option(dir, "markdown", "redcarpet")
  end

  def self.showoff_renderer_options(dir = '.', default_options = {})
    opts = get_config_option(dir, showoff_markdown(dir))
    Hash[opts.map {|k, v| [k.to_sym, v]}] if opts    # keys must be symbols
  end

  def self.get_config_option(dir, option, default = nil)
    index = File.join(dir, ShowOffUtils.presentation_config_file)
    if File.exists?(index)
      data = JSON.parse(File.read(index))
      if data.is_a?(Hash)
        if default.is_a?(Hash)
          default.merge(data[option] || {})
        else
          data[option] || default
        end
      end
    else
      default
    end
  end

  EXTENSIONS =  {
    'pl' => 'perl',
    'rb' => 'ruby',
    'erl' => 'erlang',
    # so not exhaustive, but probably good enough for now
  }

  def self.lang(source_file)
    ext = File.extname(source_file).gsub(/^\./,'')
    EXTENSIONS[ext] || ext
  end

  REQUIRED_GEMS = %w(redcarpet showoff heroku)

  # Creates the file that lists the gems for heroku
  #
  # filename  - String name of the file
  # password  - Boolean to indicate if we are setting a password
  # force     - Boolean to indicate if we should overwrite the existing file
  # formatter - Proc/lambda that takes 1 argument, the gem name, and formats it for the file
  #             This is so we can support both the old .gems and the new bundler Gemfile
  # header    - Proc/lambda that creates any header information in the file
  #
  # Returns a boolean indicating that we had to create the file or not.
  def self.create_gems_file(filename,password,force,formatter,header=nil)
    create_file_if_needed(filename,force) do |file|
      file.puts header.call unless header.nil?
      REQUIRED_GEMS.each { |gem| file.puts formatter.call(gem) }
      file.puts formatter.call("rack") if password
    end
  end

  # Creates the given filename if it doesn't exist or if force is true
  #
  # filename - String name of the file to create
  # force    - if true, the file will always be created, if false, only create
  #            if it's not there
  # block    - takes a block that will be given the file handle to write
  #            data into the file IF it's being created
  #
  # Examples
  #
  #   create_file_if_needed("config.ru",false) do |file|
  #     file.puts "require 'showoff'"
  #     file.puts "run ShowOff.new"
  #   end
  #
  # Returns true if the file was created
  def self.create_file_if_needed(filename,force)
    if !File.exists?(filename) || force
      File.open(filename, 'w+') do |f|
        yield f
      end
      true
    else
      puts "#{filename} exists; not overwriting (see showoff help heroku)"
      false
    end
  end
end

# Load the configuration for the markdown engine from the showoff.json
# file
module MarkdownConfig
  def self.setup(dir_name)
    # Load markdown configuration
    case ShowOffUtils.showoff_markdown(dir_name)

    when 'rdiscount'
      Tilt.prefer Tilt::RDiscountTemplate, "markdown"

    when 'maruku'
      Tilt.prefer Tilt::MarukuTemplate, "markdown"
      # Now check if we can go for latex mode
      require 'maruku'
      require 'maruku/ext/math'

      # Load maruku options
      opts = ShowOffUtils.showoff_renderer_options(dir_name,
                                                   { :use_tex => false,
                                                     :png_dir => 'images',
                                                     :html_png_url => '/file/images/'})

      if opts[:use_tex]
        MaRuKu::Globals[:html_math_output_mathml] = false
        MaRuKu::Globals[:html_math_engine] = 'none'
        MaRuKu::Globals[:html_math_output_png] = true
        MaRuKu::Globals[:html_png_engine] =  'blahtex'
        MaRuKu::Globals[:html_png_dir] = opts[:png_dir]
        MaRuKu::Globals[:html_png_url] = opts[:html_png_url]
      end

    when 'bluecloth'
      Tilt.prefer Tilt::BlueClothTemplate, "markdown"

    when 'kramdown'
      Tilt.prefer Tilt::KramdownTemplate, "markdown"

    else
      Tilt.prefer Tilt::RedcarpetTemplate, "markdown"

    end
  end
end
