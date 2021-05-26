module Rx
  module Check
    class Result
      def self.from(check_name)
        start_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        err = nil
        result = false

        begin
          result = yield
        rescue StandardError => ex
          err = ex
        end

        end_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)

        Result.new(check_name, result, ((end_at - start_at) * 1000).round(2), err)
      end

      attr_reader :name, :timing, :error

      def initialize(name, ok, timing, error)
        @name = name
        @ok = ok
        @timing = timing
        @error = error
      end

      def ok?
        @ok
      end
    end
  end
end