require "test_helper"

class RxUtilHeapTest < Minitest::Test
  def test_it_accepts_initial_items
    heap = Rx::Util::Heap.new([3, 2, 1])
    assert_equal 3, heap.instance_variable_get(:@heap).length
  end

  def test_it_works_like_a_min_heap
    heap = Rx::Util::Heap.new
    100.times { heap << (rand * 1000).floor }

    n = Float::INFINITY * -1

    while !heap.empty?
      value = heap.pop
      assert n <= value
      n = value
    end
  end

  def test_it_takes_a_custom_comparator
    heap = Rx::Util::Heap.new(["w", "f", "a", "i", "z"]) do |a, b|
      a.bytes[0] > b.bytes[0]
    end

    assert_equal "z", heap.pop
    assert_equal "w", heap.pop
    assert_equal "i", heap.pop
    assert_equal "f", heap.pop
    assert_equal "a", heap.pop
  end

  def test_peek_returns_an_element_without_removing_it
    heap = Rx::Util::Heap.new([10, 5])
    assert_equal 5, heap.peek
    assert_equal 2, heap.length
  end
end