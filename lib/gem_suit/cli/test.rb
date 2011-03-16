module GemSuit
  class CLI < Thor
    module Test

      def self.included(base)
        base.send :include, InstanceMethods
      end

      module InstanceMethods
      end

    end
  end
end