require_relative "../util/heap"

module Rx
  module Cache
    class InMemoryCache
      def initialize
        @heap = Rx::Util::Heap.new do |a, b|
          a[1] < b[1]
        end
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
          map[k]
        end
      end

      def put(k, v, expires_in = 60)
        lock.synchronize do
          map[k] = v
          heap << [k, Time.now + expires_in]
        end
      end

      private
      attr_reader :heap, :lock, :map

      def clean!
        lock.synchronize do
          while !heap.peek.nil? && heap.peek[1] < Time.now
            map.delete(heap.pop[0])
          end
        end
      end
    end
  end
end