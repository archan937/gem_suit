require "thor"
require "yaml"
require "rich/support/core/string/colorize"
require "gem_suit/cli/utils"
require "gem_suit/cli/config"
require "gem_suit/cli/builder"
require "gem_suit/cli/application"
require "gem_suit/cli/test"
require "gem_suit/version"

# + suit tailor
# - suit up
# - suit fit (setup)
# + suit restore
# + suit write
# + suit server
# + suit console
# - suit test
# - suit test:unit
# - suit test:functionals
# - suit test:integration
# - suit test:suit (integrator)

module GemSuit
  class CLI < Thor

    class Error < StandardError; end

    include Utils
    include Config
    include Builder
    include Application
    include Test

    desc "tailor NAME", "Generate a Bundler gem and provide it with GemSuit"
    method_options [:interactive, "-i"] => false, [:mysql, "-m"] => :boolean, [:capybara, "-c"] => :boolean, [:verbose, "-v"] => false
    def tailor(name)
      bundle_cmd = "bundle gem #{name}"
      options.verbose? ? system(bundle_cmd) : `#{bundle_cmd}`
      system "cd #{name} && suit up #{"-i" if options.interactive?}"
    end

    desc "up", "Provide an existing gem with GemSuit"
    method_options [:interactive, "-i"] => false, [:mysql, "-m"] => :boolean, [:capybara, "-c"] => :boolean, [:verbose, "-v"] => false
    def up
      assert_gem_dir true
      create_shared_assets
      configure_suit
      write_templates
      rails_new 2
      rails_new 3
      create_symlinks
      system "suit fit #{"-v" if options.verbose?}"
    end

    desc "config", "Configure GemSuit within your gem"
    method_options [:mysql, "-m"] => :boolean, [:capybara, "-c"] => :boolean
    def config
      assert_suit_dir
      if options.empty?
        puts suit_config.dump, true
      else
        options.each do |key, value|
          suit_config[key.to_sym] = value
        end
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
      files :restore, options.verbose?
    end

    desc "write", "Write all files within the GemSuit test applications"
    method_options [:verbose, "-v"] => false
    def write
      files :write, options.verbose?
    end

    desc "server", "Start one of the GemSuit test application servers"
    method_options [:version, "-v"] => 3
    map "s" => :server
    def server
      rails :server, options.version
    end

    desc "console", "Start one of the GemSuit test application consoles"
    method_options [:version, "-v"] => 3
    map "c" => :console
    def console
      rails :console, options.version
    end

  private

    def method_missing(method, *args)
      raise Error, "Unrecognized command \"#{method}\". Please consult `suit help`."
    end

  end
end