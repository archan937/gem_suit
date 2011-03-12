require "gem_suit/application/utils/gemfile"

module GemSuit
  class Application < ::Thor::Group
    module Utils

      def self.included(base)
        base.extend ClassMethods
        base.send :include, InstanceMethods
      end

      module ClassMethods
        attr_accessor :_file_

        def inherited(klass)
          klass._file_ = caller.first[/^[^:]+/]
        end
      end

      module InstanceMethods
        def root_path
          defined?(Rails) ? Rails.root : File.expand_path("../..", self.class._file_)
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
            File.readlines(expand_path("config/environment.rb")).detect do |line|
              match = line.match /RAILS_GEM_VERSION\s*=\s*["']([\d\.]+)["']/
              $1 if match
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
      end

    end
  end
end