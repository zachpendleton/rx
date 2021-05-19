module Rx
  module Check
    class FileSystemCheck
      FILENAME = "rx".freeze

      attr_reader :name

      def initialize(name = "fs")
        @name = name
      end

      def check
        Result.from(name) do
          Tempfile.open(FILENAME) do |f|
            f.write("ok")
            f.flush
          end
        end
      end
    end
  end
end