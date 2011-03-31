require "gem_suit/cli/application/io_buffer"

module GemSuit
  class CLI < Thor
    module Application

      def self.included(base)
        base.send :include, InstanceMethods
      end

      module InstanceMethods

        def test_suit
          assert_suit_dir

          pattern = options.file.nil? ? (options.pattern || "**/*.rb") : "**/#{options.file}.rb"
          data    = IOBuffer.capture do |buffer|

            (options.rails_versions || major_rails_versions).each do |rails_version|
              Dir["suit/rails-#{rails_version}/dummy/test/integration/suit/#{pattern}"].each do |f|
                buffer.execute "ruby #{f} #{"-v" if options.very_verbose?}"
              end
            end
          end

          print_test_results data
        end

        def test_unit
          assert_suit_dir

          pattern = options.file.nil? ? (options.pattern || "**/*_test.rb") : "**/#{options.file}.rb"
          loader  = File.expand_path "../application/test_loader.rb", __FILE__

          if options.rails_versions == "0"
            files = Dir["suit/shared/test/unit/#{pattern}"].collect{|x| x.inspect}.join " "
            system "ruby #{loader} -I#{files}"
          else
            (options.rails_versions || major_rails_versions).each do |rails_version|
              files = Dir["suit/rails-#{rails_version}/dummy/test/unit/#{pattern}"].collect{|x| x.inspect}.join " "
              system "ruby #{loader} -I#{files}"
            end
          end
        end

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

        def rails(command, environment, args = nil)
          assert_suit_dir

          rails_version = (options.rails_version || major_rails_versions.last).to_i
          root_path     = File.expand_path "suit/rails-#{rails_version}/dummy"
          command       = case command
                          when :rake
                            "rake #{args}"
                          else
                            {2 => "script/#{command}", 3 => "rails #{command.to_s[0, 1]}"}[rails_version]
                          end

          require "suit/rails-#{rails_version}/dummy/test/suit_application.rb"
          SuitApplication.new(:verbose => options.verbose?).bundle_install

          system "cd #{root_path} && RAILS_ENV=#{environment} #{command} #{"-p #{options.port}" if options.port}"
        end

      private

        MAJOR_RAILS_VERSIONS = [2, 3]
        DESCRIPTION_MATCH    = /^Setting up test environment for (.*)$/
        LOAD_MATCH           = /^Loaded suite suit\/rails-(\d+)\/dummy\/test\/integration\/suit\/(.*)$/
        TIME_MATCH           = /^Finished in (.*)\.$/
        SUMMARY_MATCH        = /^(\d+) (\w+), (\d+) (\w+), (\d+) (\w+), (\d+) (\w+)$/

        def extract_test_results(data)
          [{}].tap do |result|
            data.output.each do |line|
              if line.match(DESCRIPTION_MATCH)
                result.last[:description] = $1
              end
              if line.match(LOAD_MATCH)
                result.last[:load] = "Rails #{$1} - #{camelize $2}"
              end
              if line.match(TIME_MATCH)
                result.last[:time] = $1
              end
              if line.match(SUMMARY_MATCH)
                result.last[:summary ] = line
                result.last[$2.to_sym] = $1
                result.last[$4.to_sym] = $3
                result.last[$6.to_sym] = $5
                result.last[$8.to_sym] = $7
                result << {}
              end
            end
            result.reject!{|x| x.empty?}
          end
        end

        def print_test_results(data)
          return if (suit_tests = extract_test_results(data)).empty?

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