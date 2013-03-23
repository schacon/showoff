$:.unshift File.expand_path("../lib", __FILE__)
require 'parade/version'

Gem::Specification.new do |s|
  s.name              = "parade"
  s.version           = Parade::VERSION
  s.date              = "2011-09-10"
  s.summary           = "The best damn presentation software a developer could ever love."
  s.homepage          = "http://github.com/burtlo/parade"
  s.email             = "franklin.webber@gmail.com"
  s.authors           = ["Scott Chacon", "Franklin Webber"]
  s.has_rdoc          = false
  s.require_path      = "lib"
  s.executables       = %w( parade )
  s.files             = %w( README.md Rakefile LICENSE )
  s.files            += Dir.glob("lib/**/*")
  s.files            += Dir.glob("bin/**/*")
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
  Parade is a Sinatra web app that reads simple configuration files for a
  presentation.  It is sort of like a Keynote web app engine.  I am using it
  to do all my talks in 2010, because I have a deep hatred in my heart for
  Keynote and yet it is by far the best in the field.

  The idea is that you setup your slide files in section subdirectories and
  then startup the parade server in that directory.  It will read in your
  parade file for which sections go in which order and then will give
  you a URL to present from.
  desc
end
