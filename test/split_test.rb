require File.expand_path "../test_helper", __FILE__

context "splitting Markdown into slides" do

  def app
    opt = {:verbose => false, :pres_dir => "test/fixtures/simple", :pres_file => 'showoff.json'}
    ShowOff.set opt
    @showoff = ShowOff.new
  end

  setup do
  end

  test "from an empty string" do
    slides = ShowOff::Slide.split ""
    assert_empty slides
  end

  test "from a simple chunk of Markdown" do
    slides = ShowOff::Slide.split <<-MARKDOWN
# One
* uno
    MARKDOWN
    assert_equal 1, slides.size
    assert_equal ["content"], slides.first.classes
    assert_equal "# One\n* uno\n", slides.first.text
  end

    test "from a simple chunk of Markdown with slide markers" do
      slides = ShowOff::Slide.split <<-MARKDOWN
!SLIDE cool
# One
* uno

!SLIDE neat
# Two
* dos
      MARKDOWN
      assert_equal 2, slides.size
      slide = slides.first
      assert_equal ["content", "cool"], slide.classes
      assert_equal "# One\n* uno\n\n", slides.first.text
      slide = slides[1]
      assert_equal ["content", "neat"], slide.classes
      assert_equal "# Two\n* dos\n", slide.text
    end

    test "from a simple chunk of Markdown with comment-style slide markers" do
      slides = ShowOff::Slide.split <<-MARKDOWN
<!SLIDE cool>
# One
* uno

<!SLIDE neat>
# Two
* dos
      MARKDOWN
      assert_equal 2, slides.size
      slide = slides.first
      assert_equal ["content", "cool"], slide.classes
      assert_equal "# One\n* uno\n\n", slides.first.text
      slide = slides[1]
      assert_equal ["content", "neat"], slide.classes
      assert_equal "# Two\n* dos\n", slide.text
    end


    test "omits empty slides" do
      slides = ShowOff::Slide.split <<-MARKDOWN
!SLIDE
# One
* uno

!SLIDE

!SLIDE
# Two
* dos
      MARKDOWN
      assert_equal 2, slides.size
    end

    test "if there are no !SLIDE markers at all, then every H1 defines a new slide" do
      slides = ShowOff::Slide.split <<-MARKDOWN
# One
* uno

# Two
* dos
      MARKDOWN
      assert_equal 2, slides.size
      slide = slides.first
      assert_equal ["content"], slide.classes
      assert_equal "# One\n* uno\n\n", slides.first.text
      slide = slides[1]
      assert_equal ["content"], slide.classes
      assert_equal "# Two\n* dos\n", slide.text
    end

    test "every H1 defines a new slide" do
      # Until we figure out how to specify this setting at the app level,
      # this option will only be set from inside this test. This test
      # will probably become simpler then.
      varied = <<-MARKDOWN
<!SLIDE>
# One
* uno

# Two
* dos
      MARKDOWN

      slides = ShowOff::Slide.split varied
      assert_equal 1, slides.size

      slides = ShowOff::Slide.split varied, :split_all_the_h1s => false
      assert_equal 1, slides.size

      slides = ShowOff::Slide.split varied, :split_all_the_h1s => true
      assert_equal 2, slides.size
      slide = slides.first
      assert_equal ["content"], slide.classes
      assert_equal "# One\n* uno\n\n", slides.first.text
      slide = slides[1]
      assert_equal ["content"], slide.classes
      assert_equal "# Two\n* dos\n", slide.text
    end

end
