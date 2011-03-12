module GemSuit
  class Application < ::Thor::Group
    module Utils
      class Gemfile

        # A simple class which derives a Gemfile

        attr_accessor :source

        def initialize(*files)
          @files = files
        end

        def gems
          @gems ||= begin
            {}.tap do
              gem_file  = @files.detect{|file| File.exists? file}
              gem_specs = File.readlines(gem_file).join "\n"
              instance_eval gem_specs
            end
          end
        end

        def source(src)
          source = src
        end

        def gem(name, *args)
          options = (args.pop if args.last.is_a?(Hash)) || {}
          options[:version] = args.first if args.first.is_a?(String)
          @gems[name] = options
        end

        def method_missing(method, *args)
          # e.g. group :test do
          # end
        end

      end
    end
  end
end