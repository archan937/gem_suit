require File.expand_path("../../../test_application.rb", __FILE__)

TestApplication.setup

class ExampleTest < ActionController::IntegrationTest

  context "My example test" do
    setup do
    end

    teardown do
    end

    should "assert css as expected" do
      visit "/"
      assert page.has_css?    "div#page"
      assert page.has_no_css? "div#paul_engel"
    end
  end

end