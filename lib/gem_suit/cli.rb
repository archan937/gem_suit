require "thor"
require "rich/support/core/string/colorize"
require "gem_suit/cli/base"
require "gem_suit/cli/config"
require "gem_suit/cli/builder"
require "gem_suit/cli/application"
require "gem_suit/version"

module GemSuit
  class CLI < Thor

    class Error < StandardError; end

    include Base
    include Config
    include Builder
    include Application

    default_task :test

    desc "tailor NAME", "Generate a Bundler gem and provide it with GemSuit"
    method_options [:interactive, "-i"] => false, [:extras, "-e"] => true, [:mysql, "-m"] => :boolean, [:capybara, "-c"] => :boolean, [:verbose, "-v"] => false
    def tailor(name)
      execute "bundle gem #{name}"

      opts = options.collect do |key, value|
        ["-", ("-no" unless value), "-#{key}"].compact.join "" if [:interactive, :extras, :mysql, :capybara, :verbose].include?(key.to_sym)
      end.compact.join " "

      system "cd #{name} && suit up #{opts}"
    end

    desc "up", "Provide an existing gem with GemSuit"
    method_options [:interactive, "-i"] => false, [:extras, "-e"] => true, [:mysql, "-m"] => :boolean, [:capybara, "-c"] => :boolean, [:verbose, "-v"] => false
    def up
      assert_gem_dir true
      create_shared_assets
      configure_suit
      create_rails_apps
      generate_files

      opts = options.collect do |key, value|
        ["-", ("-no" unless value), "-#{key}"].compact.join "" if [:verbose].include?(key.to_sym)
      end.compact.join " "

      system "suit fit #{opts} --no-rake_install"
      puts "Barney Stinson says: 'Cheers! Your gem just got a little more legend!'".green
    end

    # desc "check", "Check whether GemSuit requirements are satisfied"
    # def check
    #   assert_suit_dir
    #   # Do we have all the Rails dummy apps installed?
    #   # Barney says: 'Your gem is already awesome' || Barney says: 'Run `suit up` to be more legend'
    # end

    desc "fit", "Establish the GemSuit in your environment"
    method_options [:rake_install, "-i"] => true, [:verbose, "-v"] => false
    def fit
      assert_suit_dir
      restore
      bundle_install
      bundle_install_apps
      rake_install if options.rake_install?
      ask_mysql_password
      create_mysql_test_database
      create_development_databases
    end

    desc "config [global]", "Configure GemSuit within your gem (use `suit config global` for global config)"
    method_options [:rails_versions, "-r"] => :array, [:mysql, "-m"] => :boolean, [:capybara, "-c"] => :boolean
    def config(env = nil)
      global_options = [:rails_versions]
      case env
      when "global"
        if options.empty?
          log suit_config_global.to_str, true
        else
          options.reject{|k, v| !global_options.include? k.to_sym}.each do |key, value|
            suit_config_global[key] = value
          end
        end
      when nil
        assert_suit_dir
        if options.empty?
          log suit_config.to_str, true
        else
          options.reject{|k, v| global_options.include? k.to_sym}.each do |key, value|
            suit_config[key] = value
          end
        end
      else
        raise Error, "Invalid config enviroment #{env.inspect}"
      end
    end

    desc "server [ENVIRONMENT]", "Start one of the GemSuit test application servers"
    method_options [:rails_version, "-r"] => :integer, [:port, "-p"] => :integer
    map "s" => :server
    def server(environment = "development")
      rails :server, environment
    end

    desc "console [ENVIRONMENT]", "Start one of the GemSuit test application consoles"
    method_options [:rails_version, "-r"] => :integer
    map "c" => :console
    def console(environment = "development")
      rails :console, environment
    end

    desc "test [SECTION] [FILES]", "Run GemSuit (suit, unit, functional, integration) tests"
    method_options [:rails_versions, "-r"] => :array, [:verbose, "-v"] => false, [:very_verbose, "-w"] => false
    def test(section = "suit", file_or_pattern = nil)
      if Application::InstanceMethods.instance_methods.collect(&:to_s).include?(method = "test_#{section}")
        send method, file_or_pattern
      elsif file_or_pattern.nil?
        test_suit section
      else
        raise Error, "Unrecognized test section '#{section}'. Either leave it empty or pass 'suit', 'unit', 'functional' or 'integration'"
      end
    end

    desc "restore", "Restore all files within the GemSuit test applications"
    method_options [:verbose, "-v"] => false
    def restore
      files :restore
    end

    desc "bundle", "Run `bundle install` (should be invoked from a Rails dummy application) only when necessary (used for testing)"
    def bundle
      raise Error, "Current directory path does not match either a GemSuit directory or a Rails dummy app. Quitting." unless suit_dir? || rails_dir?

      dirs = [File.expand_path("")]
      dirs.concat Dir["suit/rails-*/dummy"] if suit_dir?
      dirs.each do |dir|
        if [`cd #{dir} && bundle check`].flatten.any?{|line| line.include? "`bundle install`"}
          puts "Running `bundle install` (this can take several minutes...)".yellow
          system "cd #{dir} && bundle install"
        end
      end
    end

  private

    def method_missing(method, *args)
      raise Error, "Unrecognized command \"#{method}\". Please consult `suit help`."
    end

  end
end