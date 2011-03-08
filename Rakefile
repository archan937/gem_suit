require "bundler"
Bundler::GemHelper.install_tasks

require "rake/testtask"
require "rake/rdoctask"

desc "Default: run tests."
task :default => :test

task :test do
  Rake::Task["test:all"].execute
end

namespace :test do
  desc "Test the GemSuit tests in Rails 2 and 3."
  task :all do
    # system "suit test:all"
  end
  desc "Test the GemSuit tests in Rails 2."
  # Rake::TestTask.new(:"rails-2") do |t|
  #   t.libs    << "lib"
  #   t.libs    << "test"
  #   t.pattern  = "test/rails-2/dummy/test/**/*_test.rb"
  #   t.verbose  = true
  end
  desc "Test the GemSuit tests in Rails 3."
  # Rake::TestTask.new(:"rails-3") do |t|
  #   t.libs    << "lib"
  #   t.libs    << "test"
  #   t.pattern  = "test/rails-3/dummy/test/**/*_test.rb"
  #   t.verbose  = true
  # end
end

desc "Generate documentation for GemSuit."
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = "rdoc"
  rdoc.title    = "GemSuit"
  rdoc.options << "--line-numbers" << "--inline-source"
  rdoc.rdoc_files.include "README.textile"
  rdoc.rdoc_files.include "MIT-LICENSE"
  rdoc.rdoc_files.include "lib/**/*.rb"
end