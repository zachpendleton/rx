require "timeout"

module Rx
  module Check
    class GenericCheck
      attr_reader :name, :timeout

      def initialize(callable, name = "generic", timeout = 0)
        @callable = callable
        @name = name
        @timeout = timeout
      end

      def check
        Result.from(name) do
          Timeout::timeout(timeout) { callable.call }
        end
      end

      private

      attr_reader :callable
    end
  end
end