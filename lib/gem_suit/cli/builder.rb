require "fileutils"

module GemSuit
  class CLI < Thor
    module Builder

      def self.included(base)
        base.send :include, InstanceMethods
      end

      module InstanceMethods
      private

        def create_shared_assets
          FileUtils.mkdir "spec"
          FileUtils.mkdir "unit"

          temp_dir = "tmp"
          Dir["{test,spec,features}"].each do |dir|
            FileUtils.mkdir temp_dir unless File.exists? temp_dir
            FileUtils.mv dir, temp_dir
          end

          FileUtils.cp_r File.expand_path(suit_path, "."), "test"

          Dir["#{temp_dir}/{test,spec,features}"].each do |dir|
            destination = File.expand_path "test/shared/test/#{File.basename(dir)}"
            FileUtils.rm destination if File.exists? destination
            FileUtils.mv dir, destination
          end
          FileUtils.rmdir temp_dir

          suit_config[:version] = GemSuit::VERSION::STRING
          # write templates
        end

        def rails_new(major_version)
          version = ""
          puts "rails new #{version} dummy"
          # `rails new #{version} dummy`
        end

        def create_symlinks

        end

        def rake_install
          cmd = "rake install"
          puts "Running 'rake install' in order to be able to run the Rails 2 generators".green
          puts cmd
          # `#{cmd}`
        end

        def ask_mysql_password
          puts "Setting up the MySQL test database".green
          puts "To be able to run integration tests (with Capybara in Firefox) we need to store your MySQL password in a git-ignored file (test/shared/mysql)"
          puts "Please provide the password of your MySQL root user: (press Enter when blank)", true

          begin
            system "stty -echo"
            password = STDIN.gets.strip
          ensure
            system "stty echo"
          end

          # file = "test/shared/mysql"
          # if password.length == 0
          #   File.delete file if File.exists? file
          # else
          #   File.open(file, "w"){|f| f << password}
          #   puts "\n"
          # end
        end

        def create_test_database
          puts "Creating the test database".green
          puts "cd test/rails-3/dummy && RAILS_ENV=test rake db:create"

          # require "test/rails-3/dummy/test/support/dummy_app.rb"
          # DummyApp.create_test_database
        end

        def print_capybara_instructions
          puts File.read(File.expand_path("../capybara", __FILE__)).colorize
        end
      end

    end
  end
end