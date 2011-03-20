require "thor"
require "gem_suit/application/actions"

module GemSuit
  class Application < ::Thor
    include Application::Actions

    STASHED_EXT = "stashed"

    def initialize(options = {:validate_root_path => true, :verbose => true})
      super [], {}, {}
      options.each do |key, value|
        send :"#{key}=", value
      end
    end

    class << self
      def source_root
        @source_root
      end

      def source_root=(path)
        @source_root = path
      end
    end

  end
end