require "thor/shell/basic"

module GemSuit
  class CLI < Thor
    module Utils

      def self.included(base)
        base.send :include, InstanceMethods
      end

      module InstanceMethods
      protected

        def shell
          @shell ||= Thor::Shell::Basic.new
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

        def execute(command, force = nil)
          options.verbose? || force ? system(command) : `#{command}`
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

        alias_method :_puts, :puts
        def puts(string, force = false)
          _puts string if options.verbose? || force
        end

      end

    end
  end
end