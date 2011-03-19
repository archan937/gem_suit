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

        def suit_path
          File.expand_path "../../../../suit", __FILE__
        end

        def templates_path
          File.expand_path "../../../../templates", __FILE__
        end

        def agree?(question, default)
          opts   = %w(y n).collect{|x| x =~ is?(default) ? x.upcase : x}
          answer = ask("#{question} [#{opts}]") if options.interactive?
          answer = default.to_s if answer.empty?
          !!(answer =~ is?(:yes))
        end

        def ask(*args)
          shell.ask *args
        end

        def is?(*args)
          shell.send :is?, *args
        end

        alias_method :_puts, :puts
        def puts(string, force = false)
          _puts string if options.verbose? || force
        end

      end

    end
  end
end