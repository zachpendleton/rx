require "test_helper"

class NoOpCacheTest < Minitest::Test
  def setup
    @cache = Rx::Cache::NoOpCache.new
  end

  def test_cache_returns_the_block_value
    assert_equal "bar", @cache.cache(:foo) { "bar" }
  end

  def test_get_and_put_do_nothing
    @cache.put(:foo, "bar")
    assert_nil @cache.get(:foo)
  end
end