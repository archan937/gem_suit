require "gem_suit/cli/utils"
require "gem_suit/cli/shell"

module GemSuit
  class CLI < Thor
    module Base

      def self.included(base)
        base.send :include, CLI::Utils
        base.send :include, CLI::Shell
      end

    end
  end
end