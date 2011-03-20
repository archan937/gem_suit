require "gem_suit/cli/shell"
require "gem_suit/cli/utils"

module GemSuit
  class CLI < Thor
    module Builder

      class RailsApp
        include Shell
        # include Utils

        def initialize(version_spec, builder)
          @version_spec = version_spec
          @builder      = builder
        end

        def install
          return unless confirm_version
          generate
          bundle
        end

      private

        def options
          @builder.options
        end

        def expand_version_spec
          @version_spec == "latest" ? latest : @version_spec
        end

        def latest
          [`rails -v`.match(/\d\.\d+\.\d+/).to_s, "3.0.5"].max
        end

        def target_dir
          "test/rails-#{version(:major)}"
        end

        def generate_cmd
          "rails #{version(:major) < 3 ? "_#{version}_" : "new"} dummy"
        end

        def version(segment = nil)
          return @version if segment.nil?

          segments = @version.match(/(\d+)\.(\d+)\.(\d+)/).captures.collect &:to_i
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
          if answer = ask("Generate Rails #{version(:major)} application? You can specify another version or use 'n' to skip", version, version)
            return if answer =~ is?(:no)
            @version = answer unless answer.empty?
          end
        end

        def generate
          unless valid_version?
            log "Cannot generate Rails application with specified version #{version.inspect}".red
            return
          end

          if File.exists? target_dir
            log "Already installed a Rails #{version(:major)} application (skipping #{version})".red, true
            return
          end

          unless `gem list rails -i -v #{version}`.strip == "true"
            log "Installing Rails #{version} (this can take a while)".yellow, true
            execute "gem install rails -v=#{version}"
          end

          FileUtils.mkdir target_dir
          log "Generating Rails #{version(:major)} application"
          log generate_cmd
          execute "cd #{target_dir} && #{generate_cmd}"
        end

        def bundle

        end
      end

    end
  end
end