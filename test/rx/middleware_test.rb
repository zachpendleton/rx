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
    fs_check.expect :check, false
    @middleware.instance_variable_set(:@options, {liveness: [fs_check]})

    status, _, _ = @middleware.call({"REQUEST_PATH" => "/liveness"})
    assert_equal 503, status
  end

  def test_it_responds_to_readiness_requests
    status, headers, body = @middleware.call({"REQUEST_PATH" => "/readiness"})

    assert_equal 200, status
    assert_equal({"content-type" => "application/json"}, headers)
  end

  def test_it_ignores_non_health_check_requests
    _, _, body = @middleware.call({"REQUEST_PATH" => "/"})
    assert_equal ["response"], body
  end
end