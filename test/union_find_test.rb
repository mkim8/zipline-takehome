require_relative 'test_helper'

class UnionFindTest < Minitest::Test
  def test_union_connects_components
    uf = UnionFind.new
    uf.union(2, 1)
    uf.union(3, 2)

    assert_equal uf.find_root(1), uf.find_root(2)
    assert_equal uf.find_root(2), uf.find_root(3)
    assert_equal uf.find_root(1), uf.find_root(3)
  end
end
