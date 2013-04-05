require_relative 'spec_helper'

describe Parade::Renderers::UpdateImagePaths do

  let(:content) { IMG_WITH_SRC }

  context "when given html content with images" do
    before do
      subject.stub(:get_image_size).and_return([nil, nil])
    end

    let(:expected_content) { EXPECTED_IMG_WITH_SRC }

    it "should update the img src paths correctly" do
      subject.render(content).should eq expected_content
    end

    context "when the image src has single quotes" do
      let(:content) { IMG_WITH_SINGLE_QUOTES }

      it "should update the img src paths correctly" do
        subject.render(content).should eq expected_content
      end
    end
  end

  context "when given an external image" do

    let(:content) { IMG_WITH_EXTERNAL_SRC }
    let(:expected_content) { EXPECTED_IMG_WITH_EXTERNAL_SRC }

    it "should not update the img src paths" do
      subject.render(content).should eq expected_content
    end

  end

  context "when given a presentation path prefix" do
    before do
      subject.stub(:get_image_size).and_return([nil, nil])
    end

    let(:content) { IMG_WITH_SRC }
    let(:expected_content) { EXPECTED_IMG_WITH_PREFIXED_PATH_SRC }

    it "prepends the path to the img src" do
      subject.render(content,:presentation_path_prefix => "prefixed-path").should eq expected_content
    end

  end

  context "when Magick has been installed" do
    context "when given html content with images" do
      context "when the image size returns a height and width" do
        before do
          subject.should_receive(:get_image_size).with("/home/application/path/to/some/image.png", :root_path => "/home/application/").and_return([101,99])
        end

        let(:expected_content) { EXPECTED_IMG_WITH_W_AND_H }

        it "should update the img src paths correctly" do
          subject.render(content, :root_path => "/home/application/").should eq expected_content
        end
      end
    end
  end

end
