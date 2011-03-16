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

  private

    def method_missing(method, *args)
      raise Error, "Unrecognized command \"#{method}\". Please consult `suit help`."
    end

  end
end