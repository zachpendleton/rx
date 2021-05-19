require "test_helper"

class FileSystemCheckTest < Minitest::Test
  def setup
    @check = Rx::Check::FileSystemCheck.new
  end

  def test_it_returns_true_on_success
    result = @check.check
    assert result.ok?
  end

  def test_it_returns_false_on_error
    Tempfile.stub :open, -> { raise StandardError.new } do
      result = @check.check
      assert !result.ok?
    end
  end

  def test_it_stores_last_error_on_failure
    Tempfile.stub :open, -> { raise StandardError.new } do
      result = @check.check
      assert_kind_of StandardError, result.error
    end
  end

  def test_it_tracks_timing_information
    result = @check.check
    assert result.timing
  end
end