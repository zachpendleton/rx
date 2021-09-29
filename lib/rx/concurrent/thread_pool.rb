require "thread"

module Rx
  module Concurrent
    class ThreadPool
      def initialize(size = Etc.nprocessors)
        @pool = []
        @size = size
        @pid = Process.pid
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
        restart_on_fork if forked?

        return unless started?
        queue << block
      end

      private
      attr_reader :pid, :pool, :queue, :size

      def forked?
        Process.pid != pid
      end

      def restart_on_fork
        restart
        @pid = Process.pid
      end

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