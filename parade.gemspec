$:.unshift File.expand_path("../lib", __FILE__)
require 'parade/version'

Gem::Specification.new do |s|
  s.name              = "parade"
  s.version           = Parade::VERSION
  s.date              = "2013-03-23"
  s.summary           = "The best damn presentation software a developer could ever love."
  s.homepage          = "http://github.com/burtlo/parade"
  s.email             = "franklin.webber@gmail.com"
  s.authors           = ["Scott Chacon", "Franklin Webber"]
  s.has_rdoc          = false
  s.require_path      = "lib"
  s.license           = "MIT"
  s.executables       = %w( parade )
  s.files             = %w( README.md Rakefile LICENSE )

  s.files            += Dir.glob("lib/**/*")
  s.files.reject! { |file| File.extname(file) =~ /\.(png|gif|png|svg)$/ }

  s.add_dependency      "sinatra", "~> 1.3"
  s.add_dependency      "redcarpet"
  s.add_dependency      "nokogiri"
  s.add_dependency      "json"
  s.add_dependency      "blankslate", '2.1.2.4'
  s.add_dependency      "gli","~> 1.6.0"
  s.add_dependency      "parslet", "1.4.0"
  s.add_dependency      "rouge", '0.2.14'
  s.add_dependency      "css_parser"
  s.add_development_dependency "mg"
  s.description       = <<-desc
  Parade is an open source presentation software that consists of a Sinatra web
app that serves up markdown files in a presentation format. Parade can serve a
directory or be configured to run with a simple configuration file.

  * Markdown backed data

      > This ultimately makes it easier to manage diffs when making changes,
      using the content in other documents, and quickly re-using portions of a
      presentation.

  * Syntax Highlighting

      > Using GitHub flavored markdown, code fences will automatically be
      syntax highlighted, making it incredibly easy to integrate code samples.

  * Code Execution

      > Slides are able to provide execution and show results for JavaScript
      and Coffeescript live within the browser. This allows for live
      demonstrations of code.

  * Web

      > Slide presentations are basically websites -- they run in your browser from your desktop. This allows for a wide range of possibilities for customization and expandability.

  * Basic Templating and Color Schemes

      > Several templates and color scheme options have been provided to help you get started. While Parade does not currently provide anything near the variety of many other presentation packages, it is well-suited for basic presentations.

  * Design Flexibility (pros and cons)

      > Unless you're skilled in CSS/Animations, you will likely have a harder
      time creating presentations with as much polish as other programs provide. However, this approach also makes Parade incredibly flexible if you do understand CSS/Animations.
desc

end
