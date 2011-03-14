module GemSuit
  module CLI
    class Suit

      # - suit tailor
      # - suit up
      # - suit fit (setup)
      # + suit restore
      # + suit write
      # + suit server
      # + suit console
      # - suit test
      # - suit test:unit
      # - suit test:functionals
      # - suit test:integration
      # - suit test:suit (integrator)

      def tailor(name)
        # Generate a Bundler gem and provide it with Rails 2 and 3 test suite
      end

      def up
        assert_valid_gemdir
        # Provide an existing gem with Rails 2 and 3 test suite
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

    private

      def assert_valid_gemdir
        if Dir["*.gemspec"].empty?
          raise Error, "Missing *.gemspec in current directory. Is this really a gem directory?"
        end
      end

      def method_missing(method, *args)
        raise Error, "Unrecognized command: '#{method}'. Please read `suit usage`."
      end

      def files(action, verbose = true)
        assert_valid_gemdir

        puts "(in #{File.expand_path("")})"

        require "test/shared/test/test_application.rb"
        application = TestApplication.new :validate_root_path => false, :verbose => false
        [2, 3].each do |rails_version|
          application.root_path = File.expand_path "test/rails-#{rails_version}/dummy"
          application.send :"#{action}_all"
        end

        puts "Done #{action.to_s[0..-2]}ing files".green if verbose
      end

      def rails(command, *args)
        assert_valid_gemdir

        rails_version = [(args.last.match(/\d+/).to_i if args.last), 3].compact.max
        root_path     = File.expand_path "test/rails-#{rails_version}/dummy"
        command       = {2 => "script/#{command}", 3 => "rails #{command.to_s[0, 1]}"}[rails_version]

        require "test/rails-#{rails_version}/dummy/test/test_application.rb"
        application = TestApplication.new :verbose => false
        application.bundle_install

        system "cd #{root_path} && #{command}"
      end

    end
  end
end