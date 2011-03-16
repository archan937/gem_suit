module GemSuit
  class CLI
    module Utils

      def self.included(base)
        base.send :include, InstanceMethods
      end

      module InstanceMethods

        def help
          puts File.read(File.expand_path("../help.txt", __FILE__)).colorize
        end

        def assert_valid_gemdir
          if Dir["*.gemspec"].empty?
            raise Error, "Missing *.gemspec in current directory. Is this really a gem directory?"
          end
        end

      end

    end
  end
end