import node


method get_value*(n: Node, x: seq[float]): float {.gcsafe.} =
    let value = x[n.split_column]
    let i = (value > n.split_value).int
    return n.sons[i].get_value(x)

method get_value*(n: Leaf, x: seq[float]): float {.gcsafe.} =
    n.leaf_f(x)

method get_proba*(n: Node, x: seq[float]): seq[float] {.base, gcsafe.} =
    let value = x[n.split_column]
    let i = (value > n.split_value).int
    return n.sons[i].get_proba(x)

method get_proba*(n: Leaf, x: seq[float]): seq[float] {.gcsafe.} =
    n.leaf_proba(x)