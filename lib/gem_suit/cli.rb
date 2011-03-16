require "thor"
require "rich/support/core/string/colorize"
require "gem_suit/cli/utils"
require "gem_suit/cli/builder"
require "gem_suit/cli/application"
require "gem_suit/cli/test"

# - suit tailor
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
    include Builder
    include Application
    include Test

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