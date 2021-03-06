STDOUT.sync = true

module GemSuit
  class CLI < Thor
    module Base
      module Utils

        def self.included(base)
          base.send :include, InstanceMethods
        end

        module InstanceMethods

          def execute(command, force = nil)
            options.very_verbose? || options.verbose? || force ? system(command) : `#{command}`
          end

          def log(string, force = false)
            puts string if options.very_verbose? || options.verbose? || force
          end

          def camelize(lower_case_and_underscored_word, first_letter_in_uppercase = true)
            if first_letter_in_uppercase
              lower_case_and_underscored_word.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
            else
              lower_case_and_underscored_word.to_s[0].chr.downcase + camelize(lower_case_and_underscored_word)[1..-1]
            end
          end

        private

          def assert_gem_dir(non_gemsuit = false)
            unless gem_dir?
              raise Error, "Missing *.gemspec in current directory. Is this really a gem directory?"
            end
            if non_gemsuit && suit_dir?
              raise Error, "Found .suit in current directory. Is this gem already provided with GemSuit?"
            end
          end

          def assert_suit_dir
            assert_gem_dir
            unless suit_dir?
              raise Error, "Missing .suit in current directory. Is this really a GemSuit directory?"
            end
          end

          def assert_rails_dir
            unless rails_dir?
              raise Error, "Current directory path does not match \"/suit/rails-{2,3}/dummy\". Is this really a GemSuit dummy app?"
            end
          end

          def gem_dir?
            !Dir["*.gemspec"].empty?
          end

          def suit_dir?
            gem_dir? && !Dir[".suit"].empty?
          end

          def rails_dir?
            !!File.expand_path("").match(/suit\/rails-\d\/dummy$/)
          end

          def major_rails_versions
            Dir["suit/rails-*"].collect{|dir| dir.match(/rails-(\d)/); $1}
          end

          def gem_name
            File.basename File.expand_path("")
          end

          def suit_gem_path
            File.expand_path "../../../../..", __FILE__
          end

          def templates_path
            File.expand_path "templates", suit_gem_path
          end

          def static_templates_path
            File.expand_path "static", templates_path
          end

          def dynamic_templates_path
            File.expand_path "dynamic", templates_path
          end

        end

      end
    end
  end
end