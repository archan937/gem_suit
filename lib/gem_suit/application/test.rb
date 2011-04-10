module GemSuit
  class Application < ::Thor::Group
    module Test

      def self.included(base)
        base.extend ClassMethods
        base.send :include, InstanceMethods
      end

      module ClassMethods
        def create_test_database
          self.new.create_test_database
        end

        def setup(*args)
          self.new.setup *args
        end

        def test(*args)
          self.new.test *args
        end
      end

      module InstanceMethods
        attr_accessor :config, :verbose

        def description
          # Implement in subclass
        end

        def prepare
          # Implement in subclass
        end

        def create_test_database
          write   "config/database.yml"
          execute "RAILS_ENV=test rake db:create"
        ensure
          restore "**/*.#{STASHED_EXT}"
        end

        def setup(config = {})
          @skipped_files = nil
          @config = config

          log "\n".ljust 145, "="
          log "Setting up test environment for Rails #{[rails_version, description].compact.join(" - ")}\n"
          log "\n".rjust 145, "="

          restore_all
          stash_all
          bundle_install

          prepare
          prepare_database
          @prepared = true
        end

        def test(config = {})
          setup config

          log "\n".rjust 145, "="
          log "Environment for Rails #{[rails_version, description].compact.join(" - ")} is ready for testing"
          log "=" .ljust 144, "="

          run_environment
        end

        def prepare_database
          return if @db_prepared
          if @ran_generator
            stash   "db/schema.rb"
            execute "rake db:test:purge"
            execute "RAILS_ENV=test rake db:migrate"
          else
            execute "rake db:test:load"
          end
          @db_prepared = true
        end

        def run_environment
          ENV["RAILS_ENV"] = "test"

          require File.expand_path("config/environment.rb", root_path)
          require "#{"rails/" if Rails::VERSION::MAJOR >= 3}test_help"

          begin
            require "gem_suit/integration_test"
          rescue LoadError
            gem_suit_path = File.expand_path "../../..", __FILE__
            $:.unshift gem_suit_path
            require "gem_suit/integration_test"
          end

          Dir[File.expand_path("../#{File.basename(self.class.__file__, ".rb")}/**/*.rb", self.class.__file__)].each do |file|
            next if skip? :require, file
            require file
          end

          log "\nRunning Rails #{Rails::VERSION::STRING}\n\n"
        end
      end

    end
  end
end