module GemSuit
  class CLI
    module Utils

      def self.included(base)
        base.send :include, InstanceMethods
      end

      module InstanceMethods

        def all

        end

      end

    end
  end
end