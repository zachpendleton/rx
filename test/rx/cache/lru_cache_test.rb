require "test_helper"

class RxCacheLRUCacheTest < Minitest::Test
  def setup
    @cache = Rx::Cache::LRUCache.new
  end

  def test_it_stores_values
    @cache.put(:a, "foo")
    @cache.put(:b, "bar")
    @cache.put(:c, "baz")

    assert_equal "foo", @cache.get(:a)
    assert_equal "bar", @cache.get(:b)
    assert_equal "baz", @cache.get(:c)
  end

  def test_it_clears_expired_values
    @cache.put(:test, "expired", -60)
    assert_nil @cache.get(:test)
  end

  def test_it_wraps_a_cacheable_block
    calls = []
    2.times do
      @cache.cache(:test) do
        calls << :ok
      end
    end
    assert_equal 1, calls.length
  end
end