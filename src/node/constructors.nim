import node
import leaf
import ../task
import ../impurity
import ../rule/tree_rules
import ../matrix_view

proc new_leaf*(father: Node, X: MatrixView[float], y: VectorView[float]): Leaf =
    result = new(Leaf)
    result.level = father.level + 1
    result.tree_task = father.tree_task
    father.num_sons += 1
    result.max_features = father.max_features
    result.impurity = father.impurity
    result.stop_rules = father.stop_rules
    result.leaf_f = result.get_leaf_func(X, y)
    result.num_sons = 0
    result.father = father
    father.num_sons += 1

proc new_son*(father: Node): Node =
    result = new(Node)
    result.level = father.level + 1
    result.impurity = father.impurity
    result.max_features = father.max_features
    result.tree_task = father.tree_task
    result.stop_rules = father.stop_rules
    result.father = father
    result.num_sons = 0
    father.num_sons += 1


proc new_root*(task: Task, impurity: ImpurityF = nil, stop_rules: TreeStopRules = nil, max_features: float = 1.0): Node =
    result = new(Node)
    result.level = 0
    result.max_features = max_features
    result.num_sons = 0
    result.tree_task = task
    if impurity.is_nil():
        if task == Classification:
            result.impurity = gini
        else:
            result.impurity = mse_from_mean
    else:
        result.impurity = impurity
    if not stop_rules.is_nil():
        result.stop_rules = stop_rules
    else:
        result.stop_rules = new_tree_stop_rules()

proc new_root_leaf*(X: MatrixView[float], y: VectorView[float]): Leaf =
    result = new(Leaf)
    result.leaf_f = result.get_leaf_func(X, y)
    result.num_sons = 0
