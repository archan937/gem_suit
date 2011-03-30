require "rubygems"

begin
  require "rails/all"
rescue LoadError
end

require "shoulda"
require "mocha"

begin
  require File.expand_path("../../../../lib/<%= gem_name %>", __FILE__)
rescue LoadError => e
  begin
    require File.expand_path("../../../../../lib/<%= gem_name %>", __FILE__)
  rescue LoadError
    puts "ERROR: #{e.message}\n\n"
  end
end