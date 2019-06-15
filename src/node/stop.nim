import node
import ../task

proc unique_class(y: seq[float]): bool =
    for value in y:
        if value != y[0]:
            return false
    echo y, " has one class"
    return true

proc on_creating_new_node*(n: Node, X: seq[seq[float]], y: seq[float]): bool =
    if n.tree_task == Classification:
        if unique_class(y):
            return true
    return n.level >= 3 or y.len <= 1

