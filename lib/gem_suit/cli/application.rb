module GemSuit
  class CLI
    module Application

      def self.included(base)
        base.send :include, InstanceMethods
        base.class_eval do
          method_option "gemfile", :type => :string, :banner => "Use the specified gemfile instead of Gemfile"
        end
      end

      module InstanceMethods

        def restore(verbose = true)
          files :restore, verbose
        end

        def write(verbose = true)
          files :write, verbose
        end

        def server(*args)
          rails :server, *args
        end
        alias_method :s, :server

        def console(*args)
          rails :console, *args
        end
        alias_method :c, :console

      private

        def files(action, verbose = true)
          assert_valid_gemdir

          puts "(in #{File.expand_path("")})"

          require "test/shared/test/test_application.rb"
          application = TestApplication.new :validate_root_path => false, :verbose => false
          [2, 3].each do |rails_version|
            application.root_path = File.expand_path "test/rails-#{rails_version}/dummy"
            application.send :"#{action}_all"
          end

          puts "Done #{action.to_s[0..-2]}ing files".green if verbose
        end

        def rails(command, *args)
          assert_valid_gemdir

          rails_version = [(args.last.match(/\d+/).to_i if args.last), 3].compact.max
          root_path     = File.expand_path "test/rails-#{rails_version}/dummy"
          command       = {2 => "script/#{command}", 3 => "rails #{command.to_s[0, 1]}"}[rails_version]

          require "test/rails-#{rails_version}/dummy/test/test_application.rb"
          application = TestApplication.new :verbose => false
          application.bundle_install

          system "cd #{root_path} && #{command}"
        end

      end

    end
  end
end