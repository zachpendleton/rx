require "test_helper"

class FileSystemCheckTest < Minitest::Test
  def setup
    @check = Rx::Check::FileSystemCheck.new
  end

  def test_it_returns_true_on_success
    assert @check.check
  end

  def test_it_returns_false_on_error
    Tempfile.stub :open, -> { raise StandardError.new } do
      assert !@check.check
    end
  end

  def test_it_stores_last_error_on_failure
    Tempfile.stub :open, -> { raise StandardError.new } do
      assert_kind_of StandardError, @check.last_error
    end
  end
end