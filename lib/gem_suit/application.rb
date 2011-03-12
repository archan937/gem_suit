require "thor/group"
require "gem_suit/actioncontroller"
require "gem_suit/application/utils"
require "gem_suit/application/actions"

module GemSuit
  class Application < ::Thor::Group

    include Application::Actions

    STASHED_EXT = "stashed"

    def initialize(validate_path = true)
      super [], {}, {}
      if validate_path && !root_path.match(/rails-\d/)
        log "Running a #{self.class.name} instance from an invalid path: '#{root_path}' needs to match ".red + "/rails-\\d/".yellow
        exit
      end
    end

    class << self
      def source_root
        @source_root ||= self.new.templates_path
      end
    end

  end
end