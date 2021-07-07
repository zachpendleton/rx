require "thread"
require_relative "thread_pool"

module Rx
  module Concurrent
    class Future
      @@pool = ThreadPool.new.start

      ALLOWED_STATES = %i[pending in_progress completed failed]

      attr_reader :error

      def self.execute(&block)
        Future.new(&block).execute
      end

      def self.thread_pool
        @@pool
      end

      def initialize(&block)
        @channel = Queue.new
        @state = :pending
        @work = block
      end

      def completed?
        state == :completed
      end

      def execute
        @state = :in_progress
        pool.submit do
          begin
            channel << work.call
            @state = :completed
          rescue StandardError => ex
            @error = ex
            @state = :failed
            channel.close
          end
        end

        self
      end

      def failed?
        state == :failed
      end

      def in_progress?
        state == :in_progress
      end

      def pending?
        state == :pending
      end

      def value
        if (completed? || failed?) && channel.empty?
          return @value
        end

        @value = channel.pop
      end

      private
      attr_reader :channel, :state, :work

      def pool
        @@pool
      end
    end
  end
end