require "test_helper"

class ConcurrentThreadPoolTest < Minitest::Test
  def setup
    @pool = Rx::Concurrent::ThreadPool.new
  end

  def test_it_starts
    @pool.start

    assert @pool.started?
  ensure
    @pool.shutdown if @pool
  end

  def test_it_stops
    @pool.start
    @pool.shutdown
    assert !@pool.started?
  end

  def test_it_restarts
    @pool.start
    @pool.restart

    assert @pool.started?
  ensure
    @pool.shutdown
  end

  def test_it_runs_submitted_work
    @pool.start
    channel = Queue.new
    @pool.submit { channel << true }
    assert channel.pop
  ensure
    @pool.shutdown
  end

  def test_exceptions_do_not_kill_pool_threads
    @pool.start
    channel = Queue.new
    @pool.submit { raise StandardError.new }
    @pool.submit { channel << true }

    channel.pop
    @pool.instance_variable_get(:@pool).all?(&:alive?)
  ensure
    @pool.shutdown
  end
end