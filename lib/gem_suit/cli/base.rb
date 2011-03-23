require "gem_suit/cli/base/utils"
require "gem_suit/cli/base/shell"

module GemSuit
  class CLI < Thor
    module Base

      def self.included(base)
        base.send :include, CLI::Base::Utils
        base.send :include, CLI::Base::Shell
      end

    end
  end
end