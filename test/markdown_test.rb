require File.expand_path "../test_helper", __FILE__

begin
  require 'maruku'
  do_maruku = true
rescue LoadError
  do_maruku = false
end

context "ShowOff Maruku tests" do
 
  def app
    opt = {:verbose => false, :pres_dir => "test/fixtures/maruku", :pres_file => 'showoff.json'}
    ShowOff.set opt
    ShowOff.new
  end
 
  setup do
  end
 
  test "maruku can get the index page" do
    get '/'
    assert last_response.ok?
    assert_match '<div id="preso">', last_response.body
  end
 
  test "maruku can get basic slides" do
    get '/slides'
    assert last_response.ok?
    assert_match /<h1(.*?)>My Presentation<\/h1>/, last_response.body
  end

  test "maruku transforms equation to math mode" do
    get '/slides'
    assert_match /<span class="maruku-inline"><img alt="\$\\forall/, last_response.body
  end
 
  test "maruku can math mode" do
    assert_equal "maruku", ShowOffUtils.showoff_markdown("test/fixtures/maruku")
  end
 
 
end if do_maruku
