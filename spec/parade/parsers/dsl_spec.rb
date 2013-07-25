require_relative 'spec_helper'

describe Parade::Parsers::Dsl do

  subject { described_class.parse(content,root_path: ".") }

  describe "css_classes" do

    let(:content) do
      %{
        section "Iteration 0" do
         css_classes "blue-background"
         slides "iteration-zero.md"
        end
        section "Iteration 1" do
         css_classes [ "blue-background" ]
         slides "iteration-zero.md"
        end
        section "Iteration WonderWoman" do
         css_classes "blue-background", "red-font", "white-borders"
         slides "iteration-zero.md"
        end
        section "Iteration Spiderman" do
         css_classes "blue-background red-spandex web-spitters"
         slides "iteration-zero.md"
        end
        }
    end

    describe "first section" do
      let(:section) { subject.sections.first }

      it "has the correct css classes" do
        section.css_classes.should eq [ "blue-background" ]
      end
    end

    describe "second section" do
      let(:section) { subject.sections[1] }

      it "has the correct css classes" do
        section.css_classes.should eq [ "blue-background" ]
      end
    end

    describe "third section" do
      let(:section) { subject.sections[2] }

      it "has the correct css classes" do
        section.css_classes.should eq [ "blue-background", "red-font", "white-borders" ]
      end
    end

    describe "fourth section" do
      let(:section) { subject.sections[3] }

      it "has the correct css classes" do
        section.css_classes.should eq [ "blue-background", "red-spandex", "web-spitters" ]
      end
    end

  end

end
