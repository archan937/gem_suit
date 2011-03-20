require "thor"
require "gem_suit/cli/base"

module GemSuit
  class CLI < Thor
    module Builder

      class Generator < Thor
        include Thor::Actions
        include Base

        def initialize(builder)
          @builder = builder
          self.class.source_root = dynamic_templates_path
          destination_root       = rails_root
        end

        no_tasks do
          def run
            generate
            create_symlinks
          end

          def options
            @builder.options
          end

          def locals
            @locals ||= {}
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

        def method_missing(method, *args)
          if locals.include?(method)
            locals[:method]
          else
            super
          end
        end

        def root
          File.expand_path ""
        end

        def generate
          if options.extensive?
            template "CHANGELOG.rdoc" if Dir[File.expand_path("CHANGELOG*"  )].empty?
            template "README.textile" if Dir[File.expand_path("README*"     )].empty?
            if Dir[File.expand_path("MIT-LICENSE*")].empty? && agree?("Do you want to use a MIT-LICENSE?", :yes)
              locals[:author] = ask "What is your (author) name", ""
              template "MIT-LICENSE"
            end
          end
          template "test/shared/test/test_helper.rb"
          template "test/templates/shared/Gemfile"
          template "test/templates/shared/config/database-#{suit_config[:mysql] ? "mysql" : "sqlite"}.yml", "test/templates/shared/config/database.yml"
        end

        def create_symlinks

        end

      end

    end
  end
end