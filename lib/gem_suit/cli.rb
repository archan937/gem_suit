require "rubygems"
require "rich/support/core/string/colorize"

module GemSuit
  module CLI
    extend self

    def usage
      puts <<-CONTENT

Usage

  #{"suit [action] [options]".green}

Actions

  tailor   - Generate a new gem with Bundler provided with the GemSuit test suite
  up       - Provide an existing gem with the GemSuit test suite
  restore  - Restore all files within the GemSuit test applications
  write    - Write all files within the GemSuit test applications
  server   - Start one of the GemSuit test application servers (alias s)
  console  - Start one of the GemSuit test application consoles (alias c)

#{"Copyright © 2011 Paul Engel, released under the MIT license".yellow}

      CONTENT
    end

    def tailor(name)
      # Generate a Bundler gem and provide it with Rails 2 and 3 test suite
    end

    def up
      # Provide existing with Rails 2 and 3 test suite
    end

    def restore(verbose = true)
      files :restore, verbose
    end

    def write(verbose = true)
      files :write, verbose
    end

    def server(*args)
      rails :server, *args
    end
    alias_method :s, :server

    def console(*args)
      rails :console, *args
    end
    alias_method :c, :console

    def method_missing(method, *args)
      puts "Unrecognized command: '#{method}' (see: 'suit usage')".red
    end

  private

    def files(action, verbose = true)
      require "test/shared/test/test_application.rb"
      application = TestApplication.new :validate_root_path => false, :verbose => false
      application.config = {:logic => :devise}
      [2, 3].each do |rails_version|
        application.root_path = File.expand_path "test/rails-#{rails_version}/dummy"
        application.send :"#{action}_all"
      end
      puts "Done #{action.to_s[0..-2]}ing files".green if verbose
    end

    def rails(command, *args)
      rails_version = [(args.last.match(/\d+/).to_i if args.last), 3].compact.max
      root_path     = File.expand_path "test/rails-#{rails_version}/dummy"
      command       = {2 => "script/#{command}", 3 => "rails #{command.to_s[0, 1]}"}[rails_version]

      restore false
      system "cd #{root_path} && #{command}"
    end

  end
end