require "test_helper"

class GenericTestHelper < Minitest::Test
  def test_it_executes_the_given_lambda
    @check = Rx::Check::GenericCheck.new(-> { true }, "test")
    result = @check.check

    assert_equal true, result.ok?
  end

  def test_it_can_have_a_name_set
    @check = Rx::Check::GenericCheck.new(-> {}, "foo")
    assert_equal "foo", @check.name
  end
end