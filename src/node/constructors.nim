import node
import leaf
import ../task
import ../impurity
import ../rule/tree_rules


proc new_leaf*(father: Node, X: seq[seq[float]], y: seq[float]): Leaf =
    result = new(Leaf)
    result.level = father.level + 1
    result.tree_task = father.tree_task
    result.impurity = father.impurity
    result.tree_rules = father.tree_rules
    result.leaf_f = result.get_leaf_func(X, y)

proc new_son*(father: Node): Node =
    result = new(Node)
    result.level = father.level + 1
    result.impurity = father.impurity
    result.tree_task = father.tree_task
    result.tree_rules = father.tree_rules

proc new_root*(task: Task, impurity: proc(y: seq[float]): float = nil, tree_rules: TreeStopRules = nil): Node =
    result = new(Node)
    result.level = 0
    result.tree_task = task
    if impurity.is_nil():
        if task == Classification:
            result.impurity = gini
        else:
            result.impurity = mse_from_mean
    else:
        result.impurity = impurity
    if not tree_rules.is_nil():
        result.tree_rules = tree_rules
    else:
        result.tree_rules = new_tree_stop_rules()

