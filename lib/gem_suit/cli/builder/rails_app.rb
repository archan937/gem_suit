require "thor"
require "gem_suit/cli/base"

module GemSuit
  class CLI < Thor
    module Builder

      class RailsApp < Thor
        include Thor::Actions
        include Base

        def initialize(version_spec, builder, confirm = true)
          @version_spec          = version_spec
          @builder               = builder
          self.class.source_root = dynamic_templates_path
          confirm_version if confirm
        end

        no_tasks do
          def install
            confirm_version
            generate
            bundle
            create_gemfile
          end

          def options
            @builder.options
          end

          def rails_gem_version
            version
          end
        end

        class << self
          def source_root
            @source_root
          end

          def source_root=(path)
            @source_root = path
          end
        end

      private

        def expand_version_spec
          @version_spec == "latest" ? latest : @version_spec
        end

        def latest
          [`rails -v`.match(/\d\.\d+\.\d+/).to_s, "3.0.5"].max
        end

        def target_dir
          File.expand_path "test/rails-#{version(:major)}"
        end

        def rails_root
          File.expand_path("dummy", target_dir)
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

        def bundled?
          !Dir[File.expand_path("Gemfile", destination_root)].empty?
        end

        def confirm_version
          @version = expand_version_spec
          answer   = ask "Generate Rails #{version(:major)} application? You can specify another version or use 'n' to skip", version, version
          if answer =~ is?(:no)
            @version = nil
            return
          end
          @version = answer unless answer.empty?
          self.destination_root = rails_root
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
          unless valid_version?
            log "Cannot bundle Rails application with specified version #{version.inspect}".red
            return
          end

          return if bundled?

          insert_into_file "config/boot.rb", File.read(File.expand_path("../boot", __FILE__)), :before => "# All that for this:\n", :verbose => false
          template "config/preinitializer.rb", :verbose => false
        end

        def create_gemfile
          template "Gemfile", :force => true, :verbose => false
        end
      end

    end
  end
end