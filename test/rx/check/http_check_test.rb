require "test_helper"
require "net/http"

class HttpCheckTest < Minitest::Test
  MockResponse = Struct.new(:code, :body)

  def setup
    @check = Rx::Check::HttpCheck.new("http://example.com")
    @http = Minitest::Mock.new
    @http.expect(:read_timeout=, nil, [1])
    @http.expect(:use_ssl=, nil, [false])
  end

  def test_it_returns_true_on_success
    @http.expect :request, MockResponse.new("200"), [Net::HTTP::Get]
    Net::HTTP.stub :new, @http do
      res = @check.check
      assert res.ok?
    end
  end

  def test_it_returns_false_on_failure
    @http.expect :request, MockResponse.new("500"), [Net::HTTP::Get]
    Net::HTTP.stub :new, @http do
      res = @check.check
      assert !res.ok?
    end
  end

  def test_it_contains_response_body_in_error
    dummy_error_message = "Dummy error message"
    @http.expect :request, MockResponse.new("500", dummy_error_message), [Net::HTTP::Get]
    Net::HTTP.stub :new, @http do
      res = @check.check
      assert !res.ok?
      assert_equal dummy_error_message, res.error.message
    end
  end

  def test_it_can_have_a_custom_name_set
    @check = Rx::Check::HttpCheck.new("http://example.com", "foo")
    assert_equal "foo", @check.name
  end

  def test_it_passes_query_params
    @check = Rx::Check::HttpCheck.new("http://example.com/expected?param=true")
    @http.expect :request, MockResponse.new("200") do |req|
      assert_equal "/expected?param=true", req.path
    end

    Net::HTTP.stub :new, @http do
      @check.check
    end
  end

  def test_it_passes_url_fragments
    @check = Rx::Check::HttpCheck.new("http://example.com/expected#fragment")
    @http.expect :request, MockResponse.new("200") do |req|
      assert_equal "/expected#fragment", req.path
    end

    Net::HTTP.stub :new, @http do
      @check.check
    end
  end

  def test_it_can_toggle_ssl
    check = Rx::Check::HttpCheck.new("https://example.com")
    http = Minitest::Mock.new
    http.expect(:read_timeout=, nil, [1])
    http.expect(:use_ssl=, nil, [true])
    http.expect :request, MockResponse.new("200")

    Net::HTTP.stub :new, http do
      check.check
    end
  end
end
