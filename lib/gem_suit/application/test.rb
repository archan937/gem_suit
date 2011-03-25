module GemSuit
  class Application < ::Thor
    module Test

      def self.included(base)
        base.extend ClassMethods
        base.send :include, InstanceMethods
      end

      module ClassMethods
        def create_test_database
          self.new.create_test_database
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

        def test(config = {})
          @config = config

          log "\n".ljust 145, "="
          log "Setting up test environment for Rails #{[rails_version, description].compact.join(" - ")}\n"
          log "\n".rjust 145, "="

          restore_all
          write_all
          bundle_install

          prepare
          prepare_database
          @prepared = true

          log "\n".rjust 145, "="
          log "Environment for Rails #{[rails_version, description].compact.join(" - ")} is ready for testing"
          log "=" .ljust 144, "="

          run_environment
        end

        def bundle_install
          return unless bundle_install?
          if verbose
            execute "bundle install", "(this can take several minutes...)"
          else
            puts "Running `bundle install` (this can take several minutes...)".yellow
            `cd #{root_path} && bundle install`
          end
        end

        def bundle_install?
          `cd #{root_path} && bundle check`.any?{|line| line.include? "`bundle install`"}
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
            require "gem_suit/actioncontroller"
          rescue LoadError
            gem_suit_path = File.expand_path "../../..", __FILE__
            $:.unshift gem_suit_path
            require "gem_suit/actioncontroller"
          end

          Dir[File.expand_path("../#{File.basename(self.class.__file__, ".rb")}/**/*.rb", self.class.__file__)].each do |file|
            require file
          end

          log "\nRunning Rails #{Rails::VERSION::STRING}\n\n"
        end
      end

    end
  end
end