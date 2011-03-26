require "yaml"

module GemSuit
  class CLI < Thor
    module Config

      class Hash
        def initialize(file, default = {})
          @filename = file
          @hash ||= ::Thor::CoreExt::HashWithIndifferentAccess.new File.exists?(@filename) ? YAML.load_file(@filename) : default
        end

        def dump
          YAML.dump hash.inject({}){|h, (k, v)| h[k.to_sym] = v; h}
        end

        def to_str
          hash.collect{|key, value| "#{key}=#{value}"}.join "\n"
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
          if hash.respond_to?(method) || method.to_s =~ /^(\w+)\?$/
            hash.send method, *args
          else
            super
          end
        end

        def hash
          @hash
        end

        def dump_file
          File.open @filename, "w" do |file|
            file << dump
          end
        end
      end

    end
  end
end