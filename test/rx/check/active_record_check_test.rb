require "test_helper"

class ActiveRecordCheckTest < Minitest::Test
  def setup
    @check = Rx::Check::ActiveRecordCheck.new
  end

  def test_it_fails_if_activerecord_is_not_defined
    result = @check.check
    assert !result.ok?
  end

  # def test_it_succeeds_if_activerecord_is_defined
  #   module ActiveRecord
  #     class Base
  #       def connection
  #         mock = Minitest::Mock.new
  #         mock.expect :active?, true

  #         mock
  #       end
  #     end
  #   end

  #   result = @check.check
  #   assert result.ok?
  # end
end