require "thread"

module Rx
  module Cache
    class MapCache
      def initialize
        @data = {}
        @lock = Mutex.new
      end

      def cache(k, expires_in = 60)
        unless (value = get(k)).nil?
          return value
        end

        value = yield
        put(k, value, expires_in)
        value
      end

      def get(k)
        lock.synchronize do
          value = data[k]
          return nil unless value

          if value[1] < Time.now
            data.delete(k)
            return nil
          end
          
          value[0]
        end
      end

      def put(k, v, expires_in = 60)
        lock.synchronize do
          data[k] = [v, Time.now + expires_in]
        end
      end

      private
      attr_reader :data, :lock
    end
  end
end