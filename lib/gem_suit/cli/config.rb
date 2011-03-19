require "gem_suit/cli/config/hash"

module GemSuit
  class CLI < Thor
    module Config

      FILENAME = ".suit"

      def self.included(base)
        base.send :include, InstanceMethods
      end

      module InstanceMethods
      private

        def suit_config_global
          @suit_config_global ||= Config.new File.expand_path(FILENAME, suit_gem_path)
        end

        def suit_config
          @suit_config ||= Config.new FILENAME, suit_config_global
        end

        def suit_config?
          File.exists? FILENAME
        end
      end

    end
  end
end