require "thor"
require "gem_suit/application/actions"
require "gem_suit/application/test"

module GemSuit
  class Application < ::Thor
    include Application::Actions
    include Application::Test

    STASHED_EXT = "stashed"

    def initialize(options = {:validate_root_path => true, :verbose => ENV["VERBOSE"]})
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