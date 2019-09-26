import node
import leaf
import ../task
import ../impurity
import ../rule/tree_rules


proc new_leaf*(father: Node, X: seq[seq[float]], y: seq[float]): Leaf =
    result = new(Leaf)
    result.level = father.level + 1
    result.tree_task = father.tree_task
    father.num_sons += 1
    result.impurity = father.impurity
    result.tree_rules = father.tree_rules
    result.leaf_f = result.get_leaf_func(X, y)
    result.num_sons = 0
    result.father = father

proc new_son*(father: Node): Node =
    result = new(Node)
    result.level = father.level + 1
    result.impurity = father.impurity
    result.tree_task = father.tree_task
    result.tree_rules = father.tree_rules
    result.father = father
    result.num_sons = 0
    father.num_sons += 1


proc new_root*(task: Task, impurity: proc(y: seq[float]): float {.gcsafe.} = nil, tree_rules: TreeGrowRules = nil): Node =
    result = new(Node)
    result.level = 0
    result.num_sons = 0
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
        result.tree_rules = new_tree_grow_rules(1.0)

proc new_root_leaf*(X: seq[seq[float]], y: seq[float]): Leaf =
    result = new(Leaf)
    result.leaf_f = result.get_leaf_func(X, y)
    result.num_sons = 0
