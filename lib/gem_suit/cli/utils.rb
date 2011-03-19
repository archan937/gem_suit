module GemSuit
  class CLI < Thor
    module Utils

      def self.included(base)
        base.send :include, InstanceMethods
      end

      module InstanceMethods

        def execute(command, force = nil)
          options.verbose? || force ? system(command) : `#{command}`
        end

        def log(string, force = false)
          puts string if options.verbose? || force
        end

      private

        def assert_gem_dir(non_gemsuit = false)
          if Dir["*.gemspec"].empty?
            raise Error, "Missing *.gemspec in current directory. Is this really a gem directory?"
          end
          if non_gemsuit && !Dir[".suit"].empty?
            raise Error, "Found .suit in current directory. Is this gem already provided with GemSuit?"
          end
        end

        def assert_suit_dir
          assert_gem_dir
          if Dir[".suit"].empty?
            raise Error, "Missing .suit in current directory. Is this really a GemSuit directory?"
          end
        end

        def suit_gem_path
          File.expand_path "../../../..", __FILE__
        end

        def suit_path
          File.expand_path "#{suit_gem_path}/suit", __FILE__
        end

        def templates_path
          File.expand_path "../../../../templates", __FILE__
        end

      end

    end
  end
end