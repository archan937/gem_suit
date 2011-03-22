module GemSuit
  class CLI < Thor
    module Application

      def self.included(base)
        base.send :include, InstanceMethods
      end

      module InstanceMethods
      private

        def test_suit
          system "suit restore"
          options.rails_versions.each do |rails_version|
            Dir["suit/rails-#{rails_version}/dummy/test/integration/suit/**/*.rb"].each do |file|
              execute "ruby #{file}"
            end
          end
        end

        def files(action)
          assert_suit_dir

          log "(in #{File.expand_path("")})"
          require "suit/shared/test/test_application.rb"
          application = TestApplication.new :validate_root_path => false, :verbose => options.verbose?
          [2, 3].each do |rails_version|
            application.root_path = File.expand_path "suit/rails-#{rails_version}/dummy"
            application.send :"#{action}_all"
          end

          log "Done #{action.to_s[0..-2]}ing files".green
        end

        def rails(command)
          assert_suit_dir

          root_path = File.expand_path "suit/rails-#{options.rails_version}/dummy"
          command   = {2 => "script/#{command}", 3 => "rails #{command.to_s[0, 1]}"}[options.rails_version]

          require "suit/rails-#{options.rails_version}/dummy/test/test_application.rb"
          TestApplication.new(:verbose => options.verbose?).bundle_install

          system "cd #{root_path} && #{command}"
        end
      end

    end
  end
end