require "yaml"

module GemSuit
  class CLI < Thor
    module Builder

      class RailsApp
        def initialize(version_spec)
          @version_spec = version_spec
        end

        def install
          return unless confirm_version
          generate
          bundle
        end

      private

        def expand_version_spec
          @version_spec == "latest" ? latest : @version_spec
        end

        def latest
          [`rails -v`.match(/\d\.\d+\.\d+/).to_s, "3.0.5"].max
        end

        def target_dir
          "test/rails-#{version[:major]}"
        end

        def generate_cmd
          "rails #{version[:major] ? "_#{version}_" : "new"} dummy"
        end

        def version(segment = nil)
          return @version if segment.nil?

          segments = @version.match(/^(\d+)\.(\d+)\.(\d+)$/).captures.collect &:to_i
          case segment
          when :major
            segments[0]
          when :minor
            segments[1]
          when :patch
            segments[2]
          end
        end

        def valid_version?
          !!version.match(/^\d+\.\d+\.\d+$/)
        end

        def confirm_version
          @version = expand_version_spec
          if answer = ask("Generate Rails #{version[:major]} application? You can specify another version or use 'n' to skip", version, version)
            return if answer =~ is?(:no)
            @version = answer unless answer.empty?
          end
        end

        def generate
          unless valid_version?
            puts "Cannot generate Rails application with specified version #{version.inspect}".red
            return
          end

          if File.exists? target_dir
            puts "Already installed a Rails #{version[:major]} application (skipping #{version})".red, true
            return
          end

          unless `gem list rails -i -v #{version}`.strip == "true"
            puts "Installing Rails #{version} (this can take a while)".yellow, true
            execute "gem install rails -v=#{version}"
          end

          FileUtils.mkdir target_dir
          puts "Generating Rails #{version} application"
          puts generate_cmd
          execute "cd #{target_dir} && #{generate_cmd}"
        end

        def bundle

        end
      end

    end
  end
end