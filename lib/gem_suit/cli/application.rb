require "gem_suit/cli/application/io_buffer"

module GemSuit
  class CLI < Thor
    module Application

      def self.included(base)
        base.send :include, InstanceMethods
      end

      module InstanceMethods
      private

        def files(action)
          assert_suit_dir

          log "(in #{File.expand_path("")})"

          require "suit/shared/test/suit_application.rb"
          application = SuitApplication.new :validate_root_path => false, :verbose => options.verbose?
          Dir["suit/rails-*/dummy"].each do |rails_root|
            application.root_path = rails_root
            application.send :"#{action}_all"
          end

          log "Done #{action.to_s[0..-2]}ing files".green
        end

        def rails(command)
          assert_suit_dir

          rails_version = options.rails_version || major_rails_versions.last
          root_path     = File.expand_path "suit/rails-#{rails_version}/dummy"
          command       = {2 => "script/#{command}", 3 => "rails #{command.to_s[0, 1]}"}[rails_version]

          require "suit/rails-#{rails_version}/dummy/test/suit_application.rb"
          SuitApplication.new(:verbose => options.verbose?).bundle_install

          system "cd #{root_path} && #{command}"
        end

        def test_suit_application
          assert_suit_dir

          data = IOBuffer.capture do |buffer|
            buffer.execute "suit restore"
            (options.rails_versions || major_rails_versions).each do |rails_version|
              Dir["suit/rails-#{rails_version}/dummy/test/integration/suit/**/*.rb"].each do |file|
                buffer.execute "ruby #{file} #{"-v" if options.very_verbose?}"
              end
            end
          end

          print_test_results data
        end

      private

        # TODO: Clean up the following

        MAJOR_RAILS_VERSIONS = [2, 3]
        DESCRIPTION_MATCH    = /^Setting up test environment for (.*)$/
        LOAD_MATCH           = /^Loaded suite suit\/rails-(\d+)\/dummy\/test\/integration\/suit\/(.*)$/
        TIME_MATCH           = /^Finished in (.*)\.$/
        SUMMARY_MATCH        = /^(\d+) (\w+), (\d+) (\w+), (\d+) (\w+), (\d+) (\w+)$/

        def print_test_results(data)
          suit_tests = data.output.inject([{}]) do |tests, line|
            if line.match(DESCRIPTION_MATCH)
              tests.last[:description] = $1
            end
            if line.match(LOAD_MATCH)
              tests.last[:load] = "Rails #{$1} - #{camelize $2}"
            end
            if line.match(TIME_MATCH)
              tests.last[:time] = $1
            end
            if line.match(SUMMARY_MATCH)
              tests.last[:summary ] = line
              tests.last[$2.to_sym] = $1
              tests.last[$4.to_sym] = $3
              tests.last[$6.to_sym] = $5
              tests.last[$8.to_sym] = $7
              tests << {}
            end
            tests
          end

          suit_tests.reject!{|x| x.empty?}

          return if suit_tests.size == 0

          keys     = [:time, :tests, :assertions, :failures, :errors]
          failures = suit_tests.inject(0) do |count, test|
                       count += 1 if (test[:failures].to_i + test[:errors].to_i > 0) || test[:time].nil?
                       count
                     end

          log "\n"
          log "".ljust(100, "=")
          log "Integration tests (#{failures} failures in #{data.finish - data.start} seconds)"
          suit_tests.each do |test|
            log ""             .ljust(100, "-")
            log "  Description".ljust(16 , ".") + ": #{description test}"
            log "  Duration"   .ljust(16 , ".") + ": #{test[:time]     }"
            log "  Summary"    .ljust(16 , ".") + ": #{test[:summary]  }"
          end
          log "".ljust(100, "=")
          log "\n"
        end

        def description(test)
          failed = (test[:failures].to_i + test[:errors].to_i > 0) || test[:tests].nil?
          ((test[:description] unless (test[:description] || "").empty?) || test[:load]).send failed ? :red : :green
        end

      end

    end
  end
end