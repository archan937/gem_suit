require "thor/shell/basic"

module GemSuit
  class CLI < Thor
    module Application
      class IOBuffer

        def self.capture(&block)
          self.new.capture &block
        end

        def capture(&block)
          @data = nil
          data.record do
            yield self
          end
        end

        def execute(command)
          IO.popen(command) do |io|
            until io.eof?
              puts (data << io.gets).last
            end
          end
        end

      private

        def data
          @data ||= BufferData.new
        end

        class BufferData
          attr_reader :output, :start, :finish

          def record(&block)
            @output = []
            @start  = Time.now
            yield
            @finish = Time.now
            self
          end

          def <<(string)
            @output << string
          end
        end

      end
    end
  end
end