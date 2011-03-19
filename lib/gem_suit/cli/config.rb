require "yaml"

module GemSuit
  class CLI < Thor
    module Config

      def self.included(base)
        base.send :include, InstanceMethods
      end

      module InstanceMethods
      private
        FILENAME = ".suit"

        class Config
          def initialize(file)
            @filename = file
          end

          def dump
            YAML.dump hash.inject({}){|h, (k, v)| h[k.to_sym] = v; h}
          end

          def [](key)
            hash[key]
          end

          def []=(key, value)
            hash[key] = value
            dump_file
          end

        private

          def method_missing(method, *args)
            if method.to_s =~ /^(\w+)\?$/
              hash.send method, *args
            else
              super
            end
          end

          def hash
            @hash ||= ::Thor::CoreExt::HashWithIndifferentAccess.new File.exists?(@filename) ? YAML.load_file(@filename) : {}
          end

          def dump_file
            File.open @filename, "w" do |file|
              file << dump
            end
          end
        end

        def suit_config
          @suit_config ||= Config.new FILENAME
        end

        def suit_config?
          File.exists? FILENAME
        end
      end

    end
  end
end