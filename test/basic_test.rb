require File.expand_path "../test_helper", __FILE__
require 'pdf/inspector'

context "ShowOff pdf tests" do

    test "configure pdf options" do

    ShowOffUtils.presentation_config_file = "test/fixtures/simple/showoff_pdf.json"
    assert_equal "A4", ShowOffUtils.pdf_options[:page_size]
    assert_equal false, ShowOffUtils.pdf_options[:print_media_type]
    
    ShowOffUtils.presentation_config_file = "test/fixtures/simple/showoff.json"
    assert_equal "Letter", ShowOffUtils.pdf_options[:page_size]

  end

end

context "ShowOff basic tests" do

  def app
    opt = {:verbose => false, :pres_dir => "test/fixtures/simple", :pres_file => 'showoff.json'}
    ShowOff.set opt
    @showoff = ShowOff.new
  end

  setup do
  end

  test "can get the index page" do
    get '/'
    assert last_response.ok?
    assert_match '<div id="preso">', last_response.body
  end

  test "can get basic slides" do
    get '/slides'
    assert last_response.ok?
    assert_match '<h1>My Presentation</h1>', last_response.body
  end

  test "can get asset list" do
    get '/assets_needed'
    assert last_response.ok?
    assets = last_response.body.split("\n")
    assert assets.include? 'css/showoff.css'
  end

  test "can view the presenter version" do
    get '/presenter'
    assert last_response.ok?
    assert_match '<div id="preso"', last_response.body
    assert_match '<div id="notes"', last_response.body
    assert_match '<div id="slides"', last_response.body
  end

  test "can create a pdf version" do
    get '/pdf'
    assert last_response.ok?

    pages = PDF::Inspector::Page.analyze(last_response.body).pages.size
    assert_equal 2, pages

    assert last_response.body.size > 5000
  end

end
