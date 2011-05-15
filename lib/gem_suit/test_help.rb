ENV["RAILS_ENV"] = "test"

caller_dir = File.dirname(caller.detect{|x| !x.include?("custom_require.rb") && !x.include?("lib/gem_suit")})
rails_root = File.expand_path "..", caller_dir
rails_root = File.expand_path Dir["#{caller_dir}/../../rails-*/dummy"].last unless File.exists? "#{rails_root}/config/environment.rb"
gem_dir    = File.expand_path "../../..", rails_root

system "cd #{gem_dir}    && suit restore"
system "cd #{rails_root} && suit bundle"

begin
  require "#{rails_root}/config/environment"
rescue LoadError => e
  puts "ERROR: #{e.message}\n\n"
end

require "#{"rails/" if Rails::VERSION::MAJOR >= 3}test_help"