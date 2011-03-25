module GemSuit
  class CLI < Thor
    module Application

      def self.included(base)
        base.send :include, InstanceMethods
      end

      module InstanceMethods
      private

        def test_suit_application
          assert_suit_dir

          execute "suit restore"
          (options.rails_versions || major_rails_versions).each do |rails_version|
            Dir["suit/rails-#{rails_version}/dummy/test/integration/suit/**/*.rb"].each do |file|
              system "ruby #{file} VERBOSE=#{options.verbose?}"
            end
          end
        end

        def files(action)
          assert_suit_dir

          log "(in #{File.expand_path("")})"

          require "suit/shared/test/suit_application.rb"
          application = SuitApplication.new :validate_root_path => false, :verbose => options.verbose?
          Dir["suit/rails-*/dummy"].each do |rails_root|
            application.root_path = rails_root
            application.send :"#{action}_all"
          end

          log "Done #{action.to_s[0..-2]}ing files".green
        end

        def rails(command)
          assert_suit_dir

          rails_version = options.rails_version || major_rails_versions.last
          root_path     = File.expand_path "suit/rails-#{rails_version}/dummy"
          command       = {2 => "script/#{command}", 3 => "rails #{command.to_s[0, 1]}"}[rails_version]

          require "suit/rails-#{rails_version}/dummy/test/suit_application.rb"
          SuitApplication.new(:verbose => options.verbose?).bundle_install

          system "cd #{root_path} && #{command}"
        end
      end

    end
  end
end