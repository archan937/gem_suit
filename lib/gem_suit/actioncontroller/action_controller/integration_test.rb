# http://techiferous.com/2010/04/using-capybara-in-rails-3 FTW!

require "capybara/rails"

module ActionController
  class IntegrationTest
    include Capybara
  end
end