require "pathname"
require "fileutils"
require "rich/support/core/string/colorize"
require "gem_suit/application/utils"

module GemSuit
  class Application < ::Thor::Group
    module Actions

      def self.included(base)
        base.extend ClassMethods
        base.send :include, Utils
        base.send :include, InstanceMethods
        base.send :include, Thor::Actions
      end

      module ClassMethods
        def setup(*args)
          self.new.setup *args
        end

        def restore_all
          self.new.restore_all true
        end

        def write_all
          self.new.write_all
        end
      end

      module InstanceMethods
        attr_accessor :config, :verbose

        def setup(config = {})
          @config = config

          log "\n".ljust 145, "="
          log "Setting up test environment for Rails #{[rails_version, description].compact.join(" - ")}\n"
          log "\n".rjust 145, "="

          restore_all
          write_all
          bundle_install

          prepare
          prepare_database
          @prepared = true

          log "\n".rjust 145, "="
          log "Environment for Rails #{[rails_version, description].compact.join(" - ")} is ready for testing"
          log "=" .ljust 144, "="

          run_environment
        end

        def description
          # Implement in subclass
        end

        def prepare
          # Implement in subclass
        end

        def locals_for_template
          # Implement in subclass
        end

        def config
          @config || {}
        end

        def locals
          @locals ||= (locals_for_template @relative_path if @relative_path) || {}
        end

        def bundle_install
          return unless bundle_install?
          if verbose
            execute "bundle install", "(this can take several minutes...)"
          else
            puts "Running `bundle install` (this can take several minutes...)".yellow
            `cd #{root_path} && bundle install`
          end
        end

        def bundle_install?
          `cd #{root_path} && bundle check`.any?{|line| line.include? "`bundle install`"}
        end

        def prepare_database
          return if @db_prepared
          if @ran_generator
            stash   "db/schema.rb"
            execute "rake db:test:purge"
            execute "RAILS_ENV=test rake db:migrate"
          else
            execute "rake db:test:load"
          end
          @db_prepared = true
        end

        def restore_all(force = nil)
          if @prepared
            unless force
              log "Cannot (non-forced) restore files after having prepared the test application" unless force.nil?
              return
            end
          end

          if File.exists?(new_files = expand_path(".new_files"))
            File.readlines(new_files).each do |line|
              delete line.strip
            end
            File.delete new_files
          end

          restore "app/models/**/*.#{STASHED_EXT}"
          restore "app/views/**/*.#{STASHED_EXT}"
          restore "db/**/*.#{STASHED_EXT}"
          restore "public/**/*.#{STASHED_EXT}"
          restore "test/**/*.#{STASHED_EXT}"
          restore "**/*.#{STASHED_EXT}"
          true
        end

        def write_all
          ["shared", "rails-#{rails_version}"].each do |dir|
            root = Pathname.new File.expand_path(dir, templates_path)
            Dir[File.expand_path("**/*", root.realpath)].each do |file|
              next if File.directory? file
              path = Pathname.new file
              write path.relative_path_from(root).to_s
            end
          end
          true
        end

        def restore(string)
          Dir[expand_path(string)].each do |file|
            next unless File.exists? stashed(file)
            delete original(file)
            log :restoring, stashed(file)
            File.rename stashed(file), original(file)
          end
        end

        def delete(string)
          Dir[expand_path(string)].each do |file|
            log :deleting, file
            File.delete file
          end

          dirname = expand_path File.dirname(string)
          return unless File.exists?(dirname)

          Dir.glob("#{dirname}/*", File::FNM_DOTMATCH) do |file|
            return unless %w(. ..).include? File.basename(file)
          end

          log :deleting, dirname
          Dir.delete dirname
        end

        def write(string)
          stash string
          create string
        end

        def stash(string)
          Dir[expand_path(string)].each do |file|
            next if new_file?(file) || File.exists?(stashed(file))
            log :stashing, original(file)
            File.rename original(file), stashed(file)
          end
        end

        def create(string)
          new_files = []

          ["shared", "rails-#{rails_version}"].each do |dir|
            root = Pathname.new File.expand_path(dir, templates_path)
            Dir[File.expand_path(string, root.realpath)].each do |file|
              next if File.directory? file
              begin
                @relative_path = Pathname.new(file).relative_path_from(root).to_s
                @locals        = nil
                new_files << @relative_path unless new_file?(expand_path(@relative_path)) || File.exists?(stashed(@relative_path))
                log :creating, expand_path(@relative_path)
                template file, expand_path(@relative_path), :verbose => false
              ensure
                @relative_path = nil
              end
            end
          end

          unless new_files.empty?
            File.open(expand_path(".new_files"), "a") do |file|
              file << new_files.collect{|x| "#{x}\n"}.join("")
            end
          end
        end

        def generate(*args)
          command = case rails_version
                    when 2
                      "script/generate"
                    when 3
                      "rails g"
                    end

          execute "#{command} #{args.join(" ")}"
        end

        def execute(command, text = "")
          return if command.to_s.gsub(/\s/, "").size == 0
          log :executing, "#{command} #{text}"
          `cd #{root_path} && #{command}`
        end

        def log(action, string = nil)
          return unless verbose
          output = [string || action]
          output.unshift action.to_s.capitalize.ljust(10, " ") unless string.nil?
          puts output.join("  ")
        end

        def method_missing(method, *args)
          if locals.include? method
            locals[method]
          else
            super
          end
        end

      private

        def run_environment
          ENV["RAILS_ENV"] = "test"

          require File.expand_path("config/environment.rb", root_path)
          require "#{"rails/" if Rails::VERSION::MAJOR >= 3}test_help"
          require "gem_suit/actioncontroller"
          Dir[File.expand_path("#{File.basename(self.class.__file__, ".rb")}/**/*.rb", File.dirname(self.class.__file__))].each do |file|
            require file
          end

          puts "\nRunning Rails #{Rails::VERSION::STRING}\n\n"
        end
      end

    end
  end
end