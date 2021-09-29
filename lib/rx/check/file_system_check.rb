module Rx
  module Check
    class FileSystemCheck
      FILENAME = "rx".freeze

      attr_reader :name, :timeout

      def initialize(name = "fs", timeout = 0)
        @name = name
        @timeout = 0
      end

      def check
        Result.from(name) do
          Timeout::timeout(timeout) do
            !!Tempfile.open(FILENAME) do |f|
              f.write("ok")
              f.flush
            end
          end
        end
      end
    end
  end
end