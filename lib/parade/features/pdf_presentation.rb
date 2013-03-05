require_relative '../helpers/template_generator'

module Parade
  module PDFPresentation
    def self.included(server)

      server.get '/pdf' do

        # TODO: Find the presentation file and/or regenerate it every time

        template_options = {  'erb_template_file' => File.join(File.dirname(__FILE__), "..", "..", "views", "pdf.erb"),
                              'custom_asset_path' => settings.presentation_directory,
                              'slides' => slides }

        html_content = TemplateGenerator.new(template_options).render

        # TODO the image references here are not full filepaths. creating issues

        kit = PDFKit.new(html_content,:page_size => 'Letter', :orientation => 'Landscape')

        send_file kit.to_file('presentation.pdf')
      end

    end
  end
end