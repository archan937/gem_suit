require "rich/support/core/string/colorize"
require "gem_suit/cli/suit"

module GemSuit
  module CLI
    extend self

    class Error < StandardError; end

    def usage
      puts <<-CONTENT

Usage

  #{"suit COMMAND [ARGS]".green}

Commands

  tailor   - Generate a new gem with Bundler provided with the GemSuit test suite
  up       - Provide an existing gem with the GemSuit test suite
  restore  - Restore all files within the GemSuit test applications
  write    - Write all files within the GemSuit test applications
  server   - Start one of the GemSuit test application servers (alias s)
  console  - Start one of the GemSuit test application consoles (alias c)

#{"Copyright © 2011 Paul Engel, released under the MIT license".yellow}

      CONTENT
    end

    def run(*args)
      begin
        Suit.new.send args.shift, *ARGV
      rescue Error => e
        puts e.message.red
      end
    end

  end
end