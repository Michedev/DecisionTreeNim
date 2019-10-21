import node
import neo

method get_value*(n: Node, x: Vector[float]): float {.base, gcsafe.} =
    let value = x[n.split_column]
    let i = (value > n.split_value).int
    return n.sons[i].get_value(x)

method get_value*(n: Leaf, x: Vector[float]): float {.gcsafe.} =
    n.leaf_f(x)

method get_proba*(n: Node, x: Vector[float]): Vector[float] {.base, gcsafe.} =
    let value = x[n.split_column]
    let i = (value > n.split_value).int
    return n.sons[i].get_proba(x)

method get_proba*(n: Leaf, x: Vector[float]): Vector[float] {.gcsafe.} =
    n.leaf_proba(x)