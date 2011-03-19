require File.expand_path("../../../test_application.rb", __FILE__)

TestApplication.setup

class RenameThisTest < ActionController::IntegrationTest

  context "My test application" do
    setup do
    end

    teardown do
    end

    # should "do something" do
    #   visit "/"
    #   assert page.has_no_css? "div#paul_engel"
    # end
  end

end