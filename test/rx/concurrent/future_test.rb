require "test_helper"

class ConcurrentFutureTest < Minitest::Test
  def test_it_can_execute
    future = Rx::Concurrent::Future.execute { "foo" }
    assert_equal "foo", future.value
  end

  def test_it_begins_in_pending_state
    future = Rx::Concurrent::Future.new { "foo" }
    assert future.pending?
  end

  def test_it_is_in_progress_while_running
    channel = Queue.new
    future = Rx::Concurrent::Future.execute { channel.pop }
    assert future.in_progress?
    channel << true
  end

  def test_it_is_completed_when_successful
    future = Rx::Concurrent::Future.execute { "foo" }
    future.value
    assert future.completed?
  end

  def test_it_is_failed_when_an_error_occurs
    future = Rx::Concurrent::Future.execute { raise StandardError.new }
    future.value
    assert future.failed?
  end

  def test_failed_futures_keep_their_error
    future = Rx::Concurrent::Future.execute { raise StandardError.new }
    future.value
    assert_kind_of StandardError, future.error
  end
end