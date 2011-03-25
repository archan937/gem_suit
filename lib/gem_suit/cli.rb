require "thor"
require "rich/support/core/string/colorize"
require "gem_suit/cli/base"
require "gem_suit/cli/config"
require "gem_suit/cli/builder"
require "gem_suit/cli/application"
require "gem_suit/version"

# + suit tailor
# + suit up
# + suit fit (setup)
# + suit restore
# + suit write
# + suit server
# + suit console
# > suit test (integrator)
# - suit test:unit
# - suit test:functionals
# - suit test:integration

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
      git_ignore

      opts = options.collect do |key, value|
        ["-", ("-no" unless value), "-#{key}"].compact.join "" if [:verbose].include?(key.to_sym)
      end.compact.join " "

      system "suit fit #{opts}"
    end

    desc "config [global]", "Configure GemSuit within your gem (use `suit config global` for global config)"
    method_options [:rails_versions, "-r"] => :array, [:mysql, "-m"] => :boolean, [:capybara, "-c"] => :boolean
    def config(env = nil)
      global_options = [:rails_versions]
      case env
      when "global"
        if options.empty?
          log suit_config_global.dump, true
        else
          options.reject{|k, v| !global_options.include? k.to_sym}.each do |key, value|
            suit_config_global[key] = value
          end
        end
      when nil
        assert_suit_dir
        if options.empty?
          log suit_config.dump, true
        else
          options.reject{|k, v| global_options.include? k.to_sym}.each do |key, value|
            suit_config[key] = value
          end
        end
      else
        raise Error, "Invalid config enviroment #{env.inspect}"
      end
    end

    desc "fit", "Establish the GemSuit in your environment"
    method_options [:verbose, "-v"] => false
    def fit
      assert_suit_dir
      rake_install
      ask_mysql_password
      create_test_database
      print_capybara_instructions
    end

    desc "restore", "Restore all files within the GemSuit test applications"
    method_options [:verbose, "-v"] => false
    def restore
      files :restore
    end

    desc "write", "Write all files within the GemSuit test applications"
    method_options [:verbose, "-v"] => false
    def write
      files :write
    end

    desc "test", "Run GemSuit tests"
    method_options [:rails_versions, "-r"] => :array, [:verbose, "-v"] => false
    def test
      test_suit_application
    end

    desc "server", "Start one of the GemSuit test application servers"
    method_options [:rails_version, "-r"] => :integer
    map "s" => :server
    def server
      rails :server
    end

    desc "console", "Start one of the GemSuit test application consoles"
    method_options [:rails_version, "-r"] => :integer
    map "c" => :console
    def console
      rails :console
    end

  private

    def method_missing(method, *args)
      raise Error, "Unrecognized command \"#{method}\". Please consult `suit help`."
    end

  end
end