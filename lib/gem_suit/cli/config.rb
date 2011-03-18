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
          attr_accessor :filename, :hash

          def initialize(file)
            @filename = filename
            @hash     = File.exists?(filename) ? YAML.load_file(filename) : {}
          end

          def [](key)
            hash[key]
          end

          def []=(key, value)
            hash[key] = value
            dump_file
          end

          def dump_file
            File.open filename, "w" do |file|
              YAML.dump hash, file
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