module Rx
  module Cache
    class InMemoryCache
      def initialize
        @lock = Mutex.new
        @map  = Hash.new
      end

      def cache(k, expires_in = 60)
        if value = get(k)
          return value
        end
        
        value = yield
        put(k, value, expires_in)
        value
      end

      def get(k)
        clean!

        lock.synchronize do
          unless map[k]
            return nil
          end

          map[k][:value]
        end
      end

      def put(k, v, expires_in = 60)
        lock.synchronize do
          map[k] = {:value => v, :expiration_time => Time.now + expires_in}
        end
      end

      private
      attr_reader :lock, :map

      def clean!
        lock.synchronize do
            map.delete_if { |k, v| v[:expiration_time] < Time.now }
        end
      end
    end
  end
end