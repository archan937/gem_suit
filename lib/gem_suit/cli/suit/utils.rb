module GemSuit
  module CLI
    class Suit
      module Utils

        def self.included(base)
          base.send :include, InstanceMethods
        end

        module InstanceMethods

          def assert_valid_gemdir
            if Dir["*.gemspec"].empty?
              raise Error, "Missing *.gemspec in current directory. Is this really a gem directory?"
            end
          end

        end

      end
    end
  end
end