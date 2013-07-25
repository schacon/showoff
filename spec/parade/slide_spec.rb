require_relative 'spec_helper'

describe Parade::Slide do

  context "when initialized with content and metadata" do
    subject { described_class.new :content => content }

    let(:content) { "content" }

    its(:content) { should eq "#{content}\n" }
    its(:metadata) { should be_instance_of Parade::Metadata }
  end

  describe "#sequence" do
    before do
      subject.sequence = expected_sequence
    end

    let(:expected_sequence) { 1 }
    its(:sequence) { should eq expected_sequence }
  end

  describe "#<<" do

    let(:content) { "new slide content" }

    context "when there is no content" do

      let(:expected_content) { "#{content}\n" }

      it "should append content correctly" do
        subject << content
        subject.content.should eq expected_content
      end
    end

    context "when there is content" do

      subject { described_class.new :content => existing_content }

      let(:existing_content) { "existing content" }

      let(:expected_content) { "#{existing_content}\n#{content}\n" }

      it "should append content correctly" do
        subject << content
        subject.content.should eq expected_content
      end

    end
  end

  describe "#empty?" do
    context "when there is no content" do
      its(:empty?) { should be_true }
    end

    context "when there is no content but the slide is marked as blank" do
      it "empty? should be false" do
        subject.metadata = Parade::Metadata.new classes: ["blank"]
        subject.should_not be_empty
      end
    end

    context "when there is content" do
      subject { described_class.new :content => 'new content' }
      its(:empty?) { should be_false }
    end
  end

  describe "#content_classes" do
    context "when created with no metadata" do
      its(:content_classes) { should eq [] }
    end

    context "when created with metadata" do
      subject { described_class.new :metadata => mock('metadata', :classes => ['one', 'two', 'three']) }
      its(:content_classes) { should eq %w[ one two three ] }
    end
  end

  describe "#section_classes" do
    context "when the section has no css classes" do
      subject { described_class.new section: mock('section',css_classes: []) }
      it "returns an empty array" do
        subject.section_classes.should eq([])
      end
    end

    context "when the section has css classes" do
      subject { described_class.new section: mock('section',css_classes: css_classes) }

      let(:css_classes) { [ "exercises", "even" ] }

      it "returns an empty array" do
        subject.section_classes.should eq(css_classes)
      end
    end
  end

  describe "#slide_classes" do
    subject do
      described_class.new section: mock('section',title: "one", css_classes: [ "two" ]),
        metadata: mock('metadata',classes: [ "three", "four", "five" ])
    end

    it "has the title, metadata classes, and the section css classes" do
      subject.slide_classes.should eq %w[ one two three four five ]
    end
  end

  describe "#transition" do
    context "when created with no metadata" do
      let(:default_transition) { "none" }
      its(:transition) { should eq default_transition }
    end

    context "when created with transition metadata" do
      subject { described_class.new :metadata => mock('metadata', :transition => 'slide') }
      let(:expected_transition) { 'slide' }

      its(:transition) { should eq expected_transition }
    end
  end

  describe "#id" do
    context "when created with no id in the metadata" do
      subject { described_class.new :metadata => mock('metadata',:id => nil) }
      its(:id) { should eq "" }
    end
    context "when created with an id in the metadata" do
      subject { described_class.new :metadata => mock('metadata',:id => 'slide_id') }
      its(:id) { should eq "slide_id" }
    end
  end

  describe "#content_as_html" do

    subject { described_class.new :content => content }

    let(:content) { 'content' }
    let(:renderer) { mock('Markdown Renderer', :render => expected_html_content) }
    let(:expected_html_content) { 'content as html' }

    it "should attempt to render the markdown content" do
      Redcarpet::Markdown.stub(:new).and_return(renderer)
      subject.content_as_html.should eq expected_html_content
    end
  end

  describe "#template_file" do

    subject { described_class.new :metadata => mock('metadata', :template => 'template') }


    it "should be an ERB template" do
      section = mock('section')
      subject.stub(:section).and_return(section)
      section.should_receive(:template).with('template').and_return('template filepath')
      File.stub(:read).with('template filepath').and_return('template content')
      subject.template_file.should be_kind_of ERB
    end
  end


  describe "#to_html" do
    let(:template) { mock('mock ERB template', :result => expected_html) }
    let(:expected_html) { 'expected html' }

    it "should render the template file" do
      subject.stub(:template_file).and_return(template)
      subject.to_html.should eq expected_html
    end
  end

end
