# heap = []
# def add(value, heap)
#   heap << value
#   sort(heap)
# end
# def sort(heap)
#   return if heap.length == 1
#   last_parent = (heap.length - 2) / 2
#   while last_parent >= 0
#     l = last_parent * 2 + 1
#     r = last_parent * 2 + 2
#     s = last_parent

#     if heap[l] < heap[last_parent]
#       s = l
#     end

#     if r < heap.length && heap[r] < heap[last_parent]
#       s = r
#     end

#     if s != last_parent
#       heap[s], heap[last_parent] = heap[last_parent], heap[s]
#     end

#     last_parent -= 1
#   end
# end

module Rx
  module Util
    class Heap
      %i[empty? length size].each do |m|
        define_method(m) { heap.send(m) }
      end

      def initialize(items = [], &comparator)
        @heap = items.dup
        @comparator = block_given? ? comparator : -> (a, b) { a < b }
        sort!
      end

      def <<(item)
        push(item)
      end

      def peek
        heap.first
      end

      def pop
        item = heap.shift
        sort!
        item
      end

      def push(item)
        heap << item
        sort!
        self
      end

      private

      attr_reader :comparator, :heap

      def left(n)
        2 * n + 1
      end

      def parent(n)
        (n - 1) / 2
      end

      def right(n)
        2 * n + 2
      end

      def sort!
        return if heap.length <= 1
        n = parent(heap.length - 1)
        while n >= 0
          l = left(n)
          r = right(n)
          s = n

          if comparator.call(heap[l], heap[s])
            s = l
          end

          if r < heap.length && comparator.call(heap[r], heap[s])
            s = r
          end

          if s != n
            heap[s], heap[n] = heap[n], heap[s]
          end

          n -= 1
        end
      end
    end
  end
end