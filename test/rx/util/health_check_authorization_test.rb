require "test_helper"

class HealthCheckAuthorizationTest < Minitest::Test
  def setup
    @env = { "HTTP_AUTHORIZATION" => "123" }
  end

  def test_it_checks_the_default_authorization
    @check = Rx::Util::HealthCheckAuthorization.new(@env, "123")
    result = @check.ok?

    assert_equal true, result
  end

  def test_it_executes_the_given_lambda_for_custom_authorization
    @check = Rx::Util::HealthCheckAuthorization.new(@env, -> (env) { true })
    result = @check.ok?

    assert_equal true, result 
  end
end