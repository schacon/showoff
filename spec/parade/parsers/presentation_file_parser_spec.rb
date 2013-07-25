require_relative 'spec_helper'

describe Parade::Parsers::PresentationFileParser do

  subject { described_class }

  context "when specifying the parade presentation file" do

    let(:filepath) { "parade" }

    let(:expected_options) do
      { :current_path => File.dirname(filepath) }
    end

    it "should use the DSL Paser" do
      Parade::Parsers::DslFileParser.should_receive(:parse).with(filepath,expected_options)
      subject.parse(filepath)
    end
  end

end
