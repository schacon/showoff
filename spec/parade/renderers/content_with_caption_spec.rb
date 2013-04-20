require_relative 'spec_helper'

describe Parade::Renderers::ContentWithCaptionRenderer do

  subject { described_class.new :css_class => 'content-with-caption',:html_element => "h2"}

  context "when given HTML with three H2 elements" do
    it "should generate the correct column output" do

      subject.render(CONTENT_WITH_CAPTION).should eq EXPECTED_CONTENT_WITH_CAPTION

    end
  end


end
