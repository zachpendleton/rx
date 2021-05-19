module Rx
  module Check
    class FileSystemCheck
      FILENAME = "rx".freeze

      attr_reader :name

      def initialize(name = "fs")
        @name = name
      end

      def check
        start_at = Time.now
        Tempfile.open(FILENAME) do |f|
          f.write("ok")
          f.flush
        end

        true
      rescue StandardError => ex
        Thread.current[:rx_fs_check_last_error] = ex

        false
      ensure
        end_at = Time.now
        Thread.current[:rx_fs_check_timing] = (end_at - start_at).round(2)
      end

      def last_error
        Thread.current[:rx_fs_check_last_error]
      end

      def timing
        Thread.current[:rx_fs_check_timing]
      end
    end
  end
end