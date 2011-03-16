module GemSuit
  class CLI
    module Utils

      def self.included(base)
        base.send :include, InstanceMethods
      end

      module InstanceMethods

        def tailor(name, options = {})

          # Generate a Bundler gem and provide it with Rails 2 and 3 test suite
        end

        def up
          assert_valid_gemdir
          # Provide an existing gem with Rails 2 and 3 test suite
        end

      end

    end
  end
end