require "rubygems"
require "rich/support/core/string/colorize"

module GemSuit
  module CLI
    extend self

    def usage
      puts <<-CONTENT.gsub(/^ {9}/, "")
        Usage

          #{"suit [action] [options]".green}

        Actions

          tailor   - Generate a new gem with Bundler provided with the GemSuit test suite
          up       - Provide an existing gem with the GemSuit test suite
          restore  - Restore all files within the GemSuit test applications
          write    - Write all files within the GemSuit test applications
          server   - Start one of the GemSuit test application servers
          console  - Start one of the GemSuit test application consoles

        #{"Copyright © 2011 Paul Engel, released under the MIT license".yellow}

      CONTENT
    end

    def tailor(name)
      # Generate a Bundler gem and provide it with Rails 2 and 3 test suite
    end

    def up
      # Provide existing with Rails 2 and 3 test suite
    end

    def restore
      require "test/shared/test/test_application.rb"
      application = TestApplication.new false
      application.silent = true
      [2, 3].each do |rails_version|
        application.root_path = File.expand_path "test/rails-#{rails_version}/dummy"
        application.restore_all
      end
    end

    def write
      require "test/shared/test/test_application.rb"
      application = TestApplication.new false
      application.silent = true
      [2, 3].each do |rails_version|
        application.root_path = File.expand_path "test/rails-#{rails_version}/dummy"
        application.write_all
      end
    end

    def method_missing(method, *args)
      puts "Unrecognized command: '#{method}' (see: 'suit usage')".red
    end

  end
end