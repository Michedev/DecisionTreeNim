import node
import typetraits


method get_value*(n: Node, x: seq[float]): float =
    let value = x[n.split_column]
    let i = (if value > n.split_value: 1 else: 0)
    return n.sons[i].get_value(x)

method get_value*(n: Leaf, x: seq[float]): float =
    n.leaf_f(x)