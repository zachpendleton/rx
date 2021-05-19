require "test_helper"

class MiddlewareTest < Minitest::Test
  def setup
    @app = -> (env) { [200, {}, ["response"]] }
    @middleware = Rx::Middleware.new(@app)
  end

  def test_it_responds_to_liveness_requests
    status, headers, body = @middleware.call({"REQUEST_PATH" => "/liveness"})

    assert_equal 200, status
    assert_equal Hash.new, headers
    assert_equal [], body
  end

  def test_liveness_fails_if_file_system_check_fails
    fs_check = Minitest::Mock.new
    fs_check.expect :check, Rx::Check::Result.new("fs", false, "err", 100)
    @middleware.instance_variable_set(:@options, {liveness: [fs_check]})

    status, _, _ = @middleware.call({"REQUEST_PATH" => "/liveness"})
    assert_equal 503, status
  end

  def test_it_responds_to_readiness_requests
    status, headers, _ = @middleware.call({"REQUEST_PATH" => "/readiness"})

    assert_equal 200, status
    assert_equal({"content-type" => "application/json"}, headers)
  end

  def test_readiness_fails_if_any_one_check_fails
    check1 = Minitest::Mock.new
    check2 = Minitest::Mock.new

    check1.expect :check, Rx::Check::Result.new("1", true, "ok", 100)
    check2.expect :check, Rx::Check::Result.new("2", false, "err", 100)
    @middleware.instance_variable_get(:@options)[:readiness] = [check1, check2]

    status, _, body = @middleware.call({"REQUEST_PATH" => "/readiness"})

    assert_equal 503, status
    assert_equal 1, body[0].scan(/200/).size
    assert_equal 2, body[0].scan(/503/).size
  end

  def test_it_responds_to_deep_requests
    status, _, _ = @middleware.call("REQUEST_PATH" => "/deep")
    assert_equal 200, status
  end

  def test_deep_check_fails_if_readiness_fails
    failing_check = Minitest::Mock.new
    failing_check.expect :check, Rx::Check::Result.new("fail", false, "err", 100)
    @middleware.instance_variable_get(:@options)[:readiness] << failing_check

    status, _, _ = @middleware.call("REQUEST_PATH" => "/deep")

    assert_equal 503, status
  end

  def test_deep_check_fails_if_any_critical_fails
    failing_check = Minitest::Mock.new
    failing_check.expect :check, Rx::Check::Result.new("fail", false, "err", 100)
    @middleware.instance_variable_get(:@options)[:deep][:critical] << failing_check

    status, _, _ = @middleware.call("REQUEST_PATH" => "/deep")

    assert_equal 503, status
  end

  def test_deep_check_succeeds_even_if_a_secondary_fails
    failing_check = Minitest::Mock.new
    failing_check.expect :check, Rx::Check::Result.new("fail", false, "err", 100)
    @middleware.instance_variable_get(:@options)[:deep][:secondary] << failing_check

    status, _, _ = @middleware.call("REQUEST_PATH" => "/deep")

    assert_equal 200, status
  end

  def test_it_ignores_non_health_check_requests
    _, _, body = @middleware.call({"REQUEST_PATH" => "/"})
    assert_equal ["response"], body
  end
end