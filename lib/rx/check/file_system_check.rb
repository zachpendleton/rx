module Rx
  module Check
    class FileSystemCheck
      FILENAME = "rx".freeze

      def initialize(name = "fs")
        @last_error = nil
        @name = name
      end

      def check
        Tempfile.open(FILENAME) do |f|
          f.write("ok")
          f.flush
        end

        true
      rescue StandardError => ex
        Thread.current[:rx_fs_check_last_error] = ex

        false
      end

      def last_error
        Thread.current[:rx_fs_check_last_error]
      end
    end
  end
end