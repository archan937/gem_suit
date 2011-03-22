require "fileutils"
require "gem_suit/cli/builder/rails_app"
require "gem_suit/cli/builder/generator"

module GemSuit
  class CLI < Thor
    module Builder

      def self.included(base)
        base.send :include, InstanceMethods
      end

      module InstanceMethods
      private

        TEST_SUITS = "{test,spec,features}"
        TEMP_DIR   = "tmp"

        # `suit up`

        def create_shared_assets
          stash_test_suites
          FileUtils.cp_r File.join(static_templates_path, "."), "."
          move_test_suits
        end

        def stash_test_suites
          return if Dir[TEST_SUITS].empty?
          FileUtils.mkdir TEMP_DIR unless File.exists? TEMP_DIR

          Dir[TEST_SUITS].each do |dir|
            FileUtils.mv dir, TEMP_DIR
          end
        end

        def move_test_suits
          Dir["#{TEMP_DIR}/#{TEST_SUITS}"].each do |dir|
            if File.basename(dir) == "test"
              Dir["#{dir}/*"].each do |entry|
                destination = File.expand_path "suit/shared/test"
                if %w(fixtures integration unit).include? File.basename(entry)
                  FileUtils.rm_rf File.expand_path(File.basename(entry), destination)
                end
                FileUtils.mv entry, destination
              end
              FileUtils.rmdir dir
            else
              destination = File.expand_path "suit/shared/#{File.basename(dir)}"
              FileUtils.rm destination if File.exists? destination
              FileUtils.mv dir, destination
            end
          end

          FileUtils.rmdir TEMP_DIR if File.exists? TEMP_DIR
        end

        def create_rails_apps
          suit_config_global[:rails_versions].each do |version|
            Builder::RailsApp.new(version, self).install
          end
        end

        def generate_files
          Builder::Generator.new(self).run
        end

        def git_ignore
          # ignore mysql_password
        end

        # `suit fit`

        def rake_install
          return if Dir["rails_generators"].empty?
          cmd = "rake install"
          log "Running 'rake install' in order to be able to run the Rails 2 generators".green
          log cmd
          `#{cmd}`
        end

        def ask_mysql_password
          return unless suit_config.mysql?
          log "Setting up the MySQL test database".green
          log "To be able to run integration tests (with Capybara in Firefox) we need to store your MySQL password in a git-ignored file (suit/shared/mysql)"
          log "Please provide the password of your MySQL root user: (press Enter when blank)", true

          begin
            system "stty -echo"
            password = STDIN.gets.strip
          ensure
            system "stty echo"
          end

          file = "suit/shared/mysql"
          if password.length == 0
            File.delete file if File.exists? file
          else
            File.open(file, "w"){|f| f << password}
            log "\n"
          end
        end

        def create_test_database
          return unless suit_config.mysql?

          rails_root = Dir["suit/rails-*/dummy"].max
          log "Creating the test database".green
          log "cd #{rails_root} && RAILS_ENV=test rake db:create"

          require File.expand_path("test/test_application.rb", rails_root)
          TestApplication.create_test_database
        end

        def print_capybara_instructions
          return unless suit_config.capybara?
          log File.read(File.expand_path("../builder/capybara", __FILE__)).colorize, true
        end
      end

    end
  end
end