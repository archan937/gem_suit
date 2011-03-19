module GemSuit
  class CLI < Thor
    module Application

      def self.included(base)
        base.send :include, InstanceMethods
      end

      module InstanceMethods
      private

        def files(action)
          assert_suit_dir

          log "(in #{File.expand_path("")})"
          require "test/shared/test/test_application.rb"
          application = TestApplication.new :validate_root_path => false, :verbose => options.verbose?
          [2, 3].each do |rails_version|
            application.root_path = File.expand_path "test/rails-#{rails_version}/dummy"
            application.send :"#{action}_all"
          end

          log "Done #{action.to_s[0..-2]}ing files".green
        end

        def rails(command)
          assert_suit_dir

          root_path = File.expand_path "test/rails-#{options.version}/dummy"
          command   = {2 => "script/#{command}", 3 => "rails #{command.to_s[0, 1]}"}[options.version]

          require "test/rails-#{options.version}/dummy/test/test_application.rb"
          application = TestApplication.new :verbose => options.verbose?
          application.bundle_install

          system "cd #{root_path} && #{command}"
        end
      end

    end
  end
end