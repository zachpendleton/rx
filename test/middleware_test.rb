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

  def test_it_ignores_non_health_check_requests
    _, _, body = @middleware.call({"REQUEST_PATH" => "/"})
    assert_equal ["response"], body
  end
end