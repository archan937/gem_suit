require "fileutils"
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
            create_symlinks
            generate
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

        def changelog?
          !Dir["CHANGELOG*"].empty?
        end

        def mit_licensed?
          !Dir["MIT-LICENSE*"].empty?
        end

        def read_me?
          !Dir["README*"].empty?
        end

        def create_symlinks
          rails_root = Dir["suit/rails-*/dummy"].max
          FileUtils.rm   File.expand_path("public/index.html", rails_root)
          FileUtils.cp_r File.expand_path("public", rails_root), "suit/shared"

          Dir["suit/rails-*/dummy"].each do |rails_root|
            %w(app/models
               app/views
               db/schema.rb
               db/seeds.rb
               public
               test).each do |relative_path|

              path = File.expand_path relative_path, rails_root

              if File.exists? path
                method = File.directory?(path) ? :rm_rf : :rm
                FileUtils.send method, path
              end

              prefix = ([".."] * relative_path.split("/").size).join("/")
              create_link path, "#{prefix}/../shared/#{relative_path}", :verbose => false
            end
          end
        end

        def generate
          if options.extras?
            template "CHANGELOG.rdoc", :verbose => false unless changelog?

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

            gemspec = File.read "#{gem_name}.gemspec"
            gemspec.gsub! "TODO: Write your email address", email  unless email .to_s.empty?
            gemspec.gsub! "TODO: Write your name"         , author unless author.to_s.empty?

            File.open "#{gem_name}.gemspec", "w" do |file|
              file << gemspec
            end
          end

          Dir["suit/rails-*/dummy"].each do |rails_root|
            file   = File.expand_path("config/routes.rb", rails_root)
            routes = File.readlines file
            routes.each_with_index do |line, index|
              next unless line.match "to delete public/index.html"
              routes[index + 1] = routes[index + 1].gsub("# ", "").gsub("welcome", "application")
              break
            end
            File.open file, "w" do |file|
              file << routes
            end
          end

          gemspec = File.read "#{gem_name}.gemspec"
          gemspec.gsub! "TODO: Write your email address", email  unless locals[:email ].to_s.empty?
          gemspec.gsub! "TODO: Write your name"         , author unless locals[:author].to_s.empty?
          File.open "#{gem_name}.gemspec", "w" do |file|
            file << gemspec
          end

          template "suit/shared/app/views/application/index.html.erb", :verbose => false
          template "suit/shared/public/stylesheets/app.css", :force => true, :verbose => false
          template "test/shared/test/test_helper.rb", :verbose => false
          template "suit/templates/shared/Gemfile", :verbose => false
          template "suit/templates/shared/config/database-#{suit_config[:mysql] ? "mysql" : "sqlite"}.yml", "suit/templates/shared/config/database.yml", :verbose => false
        end

      end

    end
  end
end