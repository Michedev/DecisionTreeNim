import node
import leaf
import ../task


proc new_leaf*(father: Node, X: seq[seq[float]], y: seq[float]): Leaf =
    result = new(Leaf)
    result.level = father.level + 1
    result.task = father.task
    result.leaf_f = result.get_leaf_func(X, y)

proc new_node*(father: Node): Node =
    result = new(Node)
    result.level = father.level + 1
    result.task = father.task

proc new_root*(task: Task): Node =
    result = new(Node)
    result.level = 0
    result.task = task
