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
          self.destination_root  = root
        end

        no_tasks do
          def run
            generate
            create_symlinks
          end

          def options
            @builder.options
          end

          def suit_config
            @builder.suit_config
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
            locals[method]
          else
            super
          end
        end

        def root
          File.expand_path ""
        end

        def mit_licensed?
          !Dir[File.expand_path("MIT-LICENSE*")].empty?
        end

        def read_me?
          !Dir[File.expand_path("README*")].empty?
        end

        def generate
          if options.extensive?
            template "CHANGELOG.rdoc", :verbose => false if Dir[File.expand_path("CHANGELOG*")].empty?

            unless mit_licensed? || !agree?("Do you want to use a MIT-LICENSE?", :yes)
              locals[:author] ||= ask "What is your author name?"
              template "MIT-LICENSE", :verbose => false
            end

            unless read_me?
              locals[:twitter] ||= ask "What is your Twitter name?"
              locals[:email]   ||= ask "What is your email address?"
              locals[:author]  ||= ask "What is your author name?"
              template "README.textile", :verbose => false
            end

            gsub_file "#{gem_name}.gemspec", /.*/, locals[:email ], :verbose => false unless locals[:email ].to_s.empty?
            gsub_file "#{gem_name}.gemspec", /.*/         , locals[:author], :verbose => false unless locals[:author].to_s.empty?
          end

          template "test/shared/test/test_helper.rb", :verbose => false
          template "test/templates/shared/Gemfile", :verbose => false
          template "test/templates/shared/config/database-#{suit_config[:mysql] ? "mysql" : "sqlite"}.yml", "test/templates/shared/config/database.yml", :verbose => false
        end

        def create_symlinks

        end

      end

    end
  end
end