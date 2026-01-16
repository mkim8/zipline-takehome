class UnionFind
  def initialize
    @parent = {}
  end

  def find_root(x)
    @parent[x] ||= x          # if x is new, it is its own parent
    return x if @parent[x] == x

    @parent[x] = find_root(@parent[x])  # path compression
  end

  def union(a, b)
    root_a = find_root(a)
    root_b = find_root(b)

    return if root_a == root_b     # already connected

    @parent[root_b] = root_a       # attach b's group to a's group, so that they share the same root
  end
end
