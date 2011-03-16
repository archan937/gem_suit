# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "gem_suit/version"

Gem::Specification.new do |s|
  s.name        = "gem_suit"
  s.version     = GemSuit::VERSION::STRING
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Paul Engel"]
  s.email       = ["paul.engel@holder.nl"]
  s.homepage    = "https://github.com/archan937/gem_suit"
  s.summary     = %q{Provide an extensive test suite (with Rails 2 and 3 integration tests) to a newly generated or existing gem}
  s.description = %q{Provide an extensive test suite (with Rails 2 and 3 integration tests) to a newly generated or existing gem}

  s.rubyforge_project = "gem_suit"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "rich_support", "~> 0.1.0"
  s.add_dependency "thor"        , "~> 0.14.6"
  s.add_dependency "capybara"    , "~> 0.4.1.2"
  s.add_dependency "launchy"     , "~> 0.4.0"
end