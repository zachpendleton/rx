module Rx
  module Check
    class GenericCheck
      attr_reader :name

      def initialize(callable, name = "generic")
        @callable = callable
        @name = name
      end

      def check
        Result.from(name) do
          callable.call
        end
      end

      private

      attr_reader :callable
    end
  end
end