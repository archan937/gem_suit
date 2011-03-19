require "thor/shell/basic"

module GemSuit
  class CLI < Thor
    module Shell

      def self.included(base)
        base.send :include, InstanceMethods
      end

      module InstanceMethods

        def shell
          @shell ||= Thor::Shell::Basic.new
        end

        def is?(*args)
          shell.send :is?, *args
        end

        def agree?(question, default = nil)
          opts   = %w(y n).collect{|x| !default.nil? && x =~ is?(default) ? x.upcase : x}
          answer = ask question, opts, default
          !!(answer =~ is?(:yes))
        end

        def ask(question, opts = nil, default = nil)
          in_brackets = [opts, default].compact.first
          statement   = [question, ("[#{in_brackets}]" unless in_brackets.nil?)].compact.join " "

          answer = shell.ask statement if options.interactive? || default.nil?
          answer.nil? || answer.empty? ? default.to_s : answer
        end

      end

    end
  end
end