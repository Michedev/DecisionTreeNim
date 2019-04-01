import node

proc on_creating_new_node*(n: Node, X: seq[seq[float]], y: seq[float]): bool =
    n.level >= 3