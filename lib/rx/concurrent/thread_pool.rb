require "thread"

module Rx
  module Concurrent
    class ThreadPool
      def initialize(size = Etc.nprocessors)
        @pool = []
        @size = size
      end

      def shutdown
        return unless started?

        queue.close
        pool.map(&:join)
        pool.clear
      end

      def start
        return if started?

        @queue = Queue.new
        size.times { pool << Thread.new(&worker) }

        self
      end

      def restart
        shutdown
        start
      end

      def started?
        pool.map(&:alive?).any?
      end

      def submit(&block)
        return unless started?
        queue << block
      end

      private
      attr_reader :pool, :queue, :size

      def worker
        -> {
          while job = queue.pop
            begin
              job.call
            rescue StandardError => _
              # do nothing
            end
          end
        }
      end
    end
  end
end