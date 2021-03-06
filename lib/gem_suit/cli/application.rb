require "gem_suit/cli/application/io_buffer"

module GemSuit
  class CLI < Thor
    module Application

      def self.included(base)
        base.send :include, InstanceMethods
      end

      module InstanceMethods

        def test_all(file_or_pattern = nil)
          test_unit
          test_functional
          test_integration
          test_suit
        end

        def test_unit(file_or_pattern = nil)
          run_tests :unit, file_or_pattern
        end

        def test_functional(file_or_pattern = nil)
          run_tests :functional, file_or_pattern
        end

        def test_integration(file_or_pattern = nil)
          run_tests :integration, file_or_pattern
        end

        def test_suit(file_or_pattern = nil)
          assert_suit_dir

          data = IOBuffer.capture do |buffer|
            (options.rails_versions || major_rails_versions).each do |rails_version|
              path  = "suit/rails-#{rails_version}/dummy/test/integration/suit/"
              match = Dir[File.join(path, "**", "#{file_or_pattern || "*"}.rb")]
              match = Dir[File.join(path, file_or_pattern)] if match.empty?

              match.each do |f|
                buffer.execute "ruby #{f} #{"-v" if options.very_verbose?}"
              end
            end
          end

          print_test_results "Suit", data
        end

      private

        def run_tests(type, file_or_pattern)
          raise ArgumentError, "Only :unit, :functional and :integration are allowed" unless [:unit, :functional, :integration].include? type

          assert_suit_dir

          loader = File.expand_path "../application/test_loader.rb", __FILE__

          proc = Proc.new do |buffer, path|
            buffer.execute "suit restore"

            match = Dir[File.join(path, "**", "#{file_or_pattern || "*"}.rb")]
            match = Dir[File.join(path, file_or_pattern)] if match.empty? && !file_or_pattern.nil?
            match.reject!{|x| x.include? "test/integration/suit/"}

            unless match.empty?
              files = match.collect{|x| x.inspect}.join " "

              section    = path.match(/suit\/([^\/]*)\//).captures[0].capitalize.gsub "-", " "
              files_desc = match.size == 1 ?
                             match.first.gsub(path, "") :
                             "#{file_or_pattern.nil? ? "All" : "Multiple"} tests"

              buffer.log     "#{section} - #{files_desc}"
              buffer.execute "ruby #{loader} #{"-I" if match.size > 1}#{files}"
              buffer.execute "suit restore"
            end
          end

          data = IOBuffer.capture do |buffer|
            if options.rails_versions == ["0"]
              proc.call buffer, "suit/shared/test/#{type}/"
            else
              (options.rails_versions || major_rails_versions).each do |rails_version|
                proc.call buffer, "suit/rails-#{rails_version}/dummy/test/#{type}/"
              end
            end
          end

          print_test_results type.to_s.capitalize, data
        end

        def files(action)
          assert_suit_dir

          log "(in #{File.expand_path("")})"

          require File.expand_path("suit/shared/test/suit_application.rb")
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
          command       = {2 => "script/#{command}", 3 => "rails #{command.to_s[0, 1]}"}[rails_version]

          require File.expand_path("suit/rails-#{rails_version}/dummy/test/suit_application.rb")
          SuitApplication.new(:verbose => options.verbose?).bundle_install

          system "cd #{root_path} && RAILS_ENV=#{environment} #{command} #{"-p #{options.port}" if options.port}"
        end

        MAJOR_RAILS_VERSIONS = [2, 3]
        DESCRIPTION_MATCH    = /^Setting up test environment for (.*)$/
        LOAD_MATCH           = /^Loaded suite suit\/rails-(\d+)\/dummy\/test\/integration\/suit\/(.*)$/
        GEM_SUIT_MATCH       = /^GemSuit: (.*)$/
        TIME_MATCH           = /^Finished in (.*)\.$/
        SUMMARY_MATCH        = /^(\d+ \w+(, )?)+$/

        def print_test_results(section, data)
          return if (suit_tests = extract_test_results(data)).empty?

          failures = suit_tests.inject(0) do |count, test|
                       count += 1 if (test[:failures].to_i + test[:errors].to_i > 0) || test[:time].nil?
                       count
                     end

          log "\n"
          log "".ljust(100, "=")
          log "#{section} tests (#{failures} failures in #{data.finish - data.start} seconds)"
          suit_tests.each do |test|
            log ""             .ljust(100, "-")
            log "  Description".ljust(16 , ".") + ": #{description test}"
            log "  Duration"   .ljust(16 , ".") + ": #{test[:time]     }"
            log "  Summary"    .ljust(16 , ".") + ": #{test[:summary]  }"
          end
          log "".ljust(100, "=")
          log "\n"
        end

        def extract_test_results(data)
          [{}].tap do |result|
            data.output.each do |line|
              if line.match(DESCRIPTION_MATCH) || line.match(GEM_SUIT_MATCH)
                result.last[:description] = $1
              end
              if line.match(LOAD_MATCH)
                result.last[:load] = "Rails #{$1} - #{camelize $2}"
              end
              if line.match(TIME_MATCH)
                result.last[:time] = $1
              end
              if line.match(SUMMARY_MATCH)
                result.last[:summary] = line
                line.scan(/\d+ \w+/).each do |match|
                  amount, type = match.split " "
                  result.last[type.to_sym] = amount
                end
                result << {}
              end
            end

            result.reject!{|x| x.empty?}
          end
        end

        def description(test)
          failed = (test[:failures].to_i + test[:errors].to_i > 0) || test[:tests].nil?
          ((test[:description] unless (test[:description] || "").empty?) || test[:load]).send failed ? :red : :green
        end

      end

    end
  end
end