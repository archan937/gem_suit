module GemSuit
  class CLI < Thor
    module Application

      def self.included(base)
        base.send :include, InstanceMethods
      end

      module InstanceMethods
      private

        def files(action, verbose)
          assert_valid_gemdir

          puts "(in #{File.expand_path("")})"

          require "test/shared/test/test_application.rb"
          application = TestApplication.new :validate_root_path => false, :verbose => verbose
          [2, 3].each do |rails_version|
            application.root_path = File.expand_path "test/rails-#{rails_version}/dummy"
            application.send :"#{action}_all"
          end

          puts "Done #{action.to_s[0..-2]}ing files".green if verbose
        end

        def rails(command, rails_version)
          assert_valid_gemdir

          root_path = File.expand_path "test/rails-#{rails_version}/dummy"
          command   = {2 => "script/#{command}", 3 => "rails #{command.to_s[0, 1]}"}[rails_version]

          require "test/rails-#{rails_version}/dummy/test/test_application.rb"
          application = TestApplication.new :verbose => false
          application.bundle_install

          system "cd #{root_path} && #{command}"
        end

      end

    end
  end
end