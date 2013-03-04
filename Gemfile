source "https://rubygems.org"

gemspec

group :development do
  gem "mg"
  gem "turn"
  gem "pdf-inspector"
end

group :test, :development do
  gem 'rspec'
  gem 'guard'
  gem 'guard-rspec'
  gem "rack-test"
end

#
# Optional to provide image embedding and resizing functionality
#
group :images do
  gem "rmagick"
end

#
# Optional to provide PDF output support
#
group :pdf do
  gem "pdfkit"
  gem "wkhtmltopdf-binary", '0.9.5.3'
end
