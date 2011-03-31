ENV["RAILS_ENV"] = "test"

dirname = File.expand_path("..", File.dirname(caller.detect{|x| !x.include? "custom_require.rb"}))
dirname = File.expand_path(Dir["#{dirname}/../rails-*/dummy"].last) unless File.exists? "#{dirname}/config/environment.rb"

system "cd #{dirname} && suit bundle"

begin
  require "#{dirname}/config/environment"
rescue LoadError => e
  puts "ERROR: #{e.message}\n\n"
end

require "#{"rails/" if Rails::VERSION::MAJOR >= 3}test_help"