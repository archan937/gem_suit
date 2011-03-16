require "gem_suit/cli/suit/utils"
require "gem_suit/cli/suit/builder"
require "gem_suit/cli/suit/application"
require "gem_suit/cli/suit/test"

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
  module CLI
    class Suit

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
end