STDOUT.sync = true

module Suite
  module Integrator
    extend self

    def run(&block)
      Test.new.run &block
    end

  private

    MAJOR_RAILS_VERSIONS = [2, 3]
    DESCRIPTION_MATCH    = /^Setting up test environment for (.*)$/
    TIME_MATCH           = /^Finished in (.*)\.$/
    SUMMARY_MATCH        = /^(\d+) (\w+), (\d+) (\w+), (\d+) (\w+), (\d+) (\w+)$/

    class Test
      def initialize
        @output = []
      end

      def run(&block)
        @start = Time.now
        yield self
        @end   = Time.now
        summarize
      end

      def test_all
        MAJOR_RAILS_VERSIONS.each{|version| test_rails version}
      end
      alias_method :all, :test_all

      def test_rails(major_version)
        system "rake restore"
        # %w(non_authenticated authenticated/devise authenticated/authlogic).each do |file|
        #   execute "ruby test/rails-#{major_version}/dummy/test/integration/#{file}.rb"
        # end
      end
      alias_method :rails, :test_rails

      def execute(command)
        IO.popen(command) do |io|
          until io.eof?
            puts (@output << io.gets).last
          end
        end
      end

      def summarize
        integration_tests = @output.inject([]) do |tests, line|
          if line.match(DESCRIPTION_MATCH)
            tests << {:description => $1.gsub(DESCRIPTION_MATCH, "")}
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
          end
          tests
        end

        return if integration_tests.size == 0

        keys     = [:time, :tests, :assertions, :failures, :errors]
        failures = integration_tests.inject(0) do |count, test|
                     count += 1 if (test[:failures].to_i + test[:errors].to_i > 0) || test[:time].nil?
                     count
                   end

        puts "\n"
        puts "".ljust(70, "=")
        puts "Integration tests (#{failures} failures in #{@end - @start} seconds)"
        integration_tests.each do |test|
          puts ""             .ljust(70, "-")
          puts "  Description".ljust(16, ".") + ": #{description test}"
          puts "  Duration"   .ljust(16, ".") + ": #{test[:time]     }"
          puts "  Summary"    .ljust(16, ".") + ": #{test[:summary]  }"
        end
        puts "".ljust(70, "=")
        puts "\n"
      end

    private

      def description(test)
        failed = (test[:failures].to_i + test[:errors].to_i > 0) || test[:tests].nil?
        test[:description].send failed ? :red : :green
      end

    end

  end
end