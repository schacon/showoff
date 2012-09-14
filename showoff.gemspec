$:.unshift File.expand_path("../lib", __FILE__)
require 'showoff/version'

Gem::Specification.new do |s|
  s.name              = "showoff"
  s.version           = SHOWOFF_VERSION
  s.date              = "2011-09-10"
  s.summary           = "The best damn presentation software a developer could ever love."
  s.homepage          = "http://github.com/schacon/showoff"
  s.email             = "schacon@gmail.com"
  s.authors           = ["Scott Chacon"]
  s.has_rdoc          = false
  s.require_path      = "lib"
  s.executables       = %w( showoff )
  s.files             = %w( README.rdoc Rakefile LICENSE )
  s.files            += Dir.glob("lib/**/*")
  s.files            += Dir.glob("bin/**/*")
  s.files            += Dir.glob("views/**/*")
  s.files            += Dir.glob("public/**/*")
  s.add_dependency      "sinatra", "~> 1.3"
  s.add_dependency      "redcarpet"
  s.add_dependency      "nokogiri"
  s.add_dependency      "json"
  s.add_dependency      "gli",">= 2.0.0"
  s.add_dependency      "parslet"
  s.add_development_dependency "mg"
  s.description       = <<-desc
  ShowOff is a Sinatra web app that reads simple configuration files for a
  presentation.  It is sort of like a Keynote web app engine.  I am using it
  to do all my talks in 2010, because I have a deep hatred in my heart for
  Keynote and yet it is by far the best in the field.

  The idea is that you setup your slide files in section subdirectories and
  then startup the showoff server in that directory.  It will read in your
  showoff.json file for which sections go in which order and then will give 
  you a URL to present from.
  desc
end
