require "gem_suit/cli/config/hash"

module GemSuit
  class CLI < Thor
    module Config

      FILENAME = ".suit"

      def self.included(base)
        base.send :include, InstanceMethods
      end

      module InstanceMethods

        def configure_suit
          suit_config_global[:rails_versions] ||= %w(2.3.11 latest)
          suit_config[:mysql]    = options.key?("mysql")    ? options.mysql    : agree?("Do you want to use a MySQL test database?", :no)
          suit_config[:capybara] = options.key?("capybara") ? options.capybara : agree?("Do you want to use Capybara for testing?" , :yes)
          suit_config[:version]  = GemSuit::VERSION::STRING
        end

        def suit_config_global
          @suit_config_global ||= Config::Hash.new File.expand_path(FILENAME, suit_gem_path)
        end

        def suit_config
          @suit_config ||= Config::Hash.new FILENAME, suit_config_global
        end

        def suit_config?
          File.exists? FILENAME
        end

      end

    end
  end
end