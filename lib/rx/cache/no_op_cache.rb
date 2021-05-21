module Rx
  module Cache
    class NoOpCache
      def cache(k, expires_in = 60)
        yield
      end

      def get(k)
        nil
      end

      def put(k, v, expires_in = 60)
        nil
      end
    end
  end
end