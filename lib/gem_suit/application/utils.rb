require "gem_suit/application/utils/gemfile"

module GemSuit
  class Application < ::Thor
    module Utils

      def self.included(base)
        base.extend ClassMethods
        base.send :include, InstanceMethods
      end

      module ClassMethods
        attr_accessor :__file__

        def inherited(klass)
          klass.__file__ = caller.first[/^[^:]+/]
        end
      end

      module InstanceMethods
        attr_accessor :root_path, :validate_root_path

        def validate_root_path!(path)
          unless path.match(/rails-\d/)
            puts caller
            log "Running a #{self.class.name} instance from an invalid path: '#{path}' needs to match ".red + "/rails-\\d/".yellow
            exit
          end
        end

        def root_path
          (@root_path || (defined?(Rails) ? Rails.root : File.expand_path("../..", self.class.__file__)).to_s).tap do |path|
            validate_root_path! path if validate_root_path
            self.class.source_root = path
          end
        end

        def shared_path
          File.expand_path("../../shared", root_path)
        end

        def templates_path
          File.expand_path("../../templates", root_path)
        end

        def expand_path(path)
          Pathname.new(path).absolute? ?
            path :
            File.expand_path(path, root_path)
        end

        def original(file)
          expand_path file.gsub(/\.#{STASHED_EXT}$/, "")
        end

        def stashed(file)
          expand_path file.match(/\.#{STASHED_EXT}$/) ? file : "#{file}.#{STASHED_EXT}"
        end

        def new_file?(file)
          return false unless File.exists? expand_path(".new_files")
          root          = Pathname.new root_path
          relative_path = Pathname.new(file).relative_path_from(root).to_s
          File.readlines(expand_path(".new_files")).any?{|line| line.strip == relative_path}
        end

        def rails_version
          root_path.match(/\/rails-(\d)\//)[1].to_i
        end

        def rails_gem_version
          case rails_version
          when 2
            File.readlines(expand_path("config/environment.rb")).each do |line|
              match = line.match /RAILS_GEM_VERSION\s*=\s*["']([\d\.]+)["']/
              return $1 if match
            end
          when 3
            files = [expand_path(stashed("Gemfile")), expand_path("Gemfile")]
            Gemfile.new(*files).gems["rails"][:version]
          end
        end

        def mysql_password
          file = File.expand_path("mysql", shared_path)
          "#{File.new(file).read}".strip if File.exists? file
        end

        def execute(command, text = "")
          return if command.to_s.gsub(/\s/, "").size == 0
          log :executing, "#{command} #{text}"
          `cd #{root_path} && #{command}`
        end

        def log(action, string = nil, force = false)
          return unless verbose || force
          output = [string || action]
          output.unshift action.to_s.capitalize.ljust(10, " ") unless string.nil?
          puts output.join("  ")
        end
      end

    end
  end
end