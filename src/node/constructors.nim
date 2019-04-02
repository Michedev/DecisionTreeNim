import node
import leaf
import ../task
import ../impurity


proc new_leaf*(father: Node, X: seq[seq[float]], y: seq[float]): Leaf =
    result = new(Leaf)
    result.level = father.level + 1
    result.task = father.task
    result.impurity = father.impurity
    result.leaf_f = result.get_leaf_func(X, y)

proc new_node*(father: Node): Node =
    result = new(Node)
    result.level = father.level + 1
    result.impurity = father.impurity
    result.task = father.task

proc new_root*(task: Task, impurity: proc(y: seq[float]): float = nil): Node =
    result = new(Node)
    result.level = 0
    result.task = task
    if impurity.is_nil():
        if task == Classification:
            result.impurity = gini
        else:
            result.impurity = mse_from_mean
    else:
        result.impurity = impurity
