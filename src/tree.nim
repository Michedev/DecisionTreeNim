import node/[node, constructors, split, sons_gen, traverse]
import task
import typetraits
import core.typeinfo
import math
import sequtils
import rule/[tree_rules, stop_rules]

type 
    DecisionTree*  = ref object
        root: Node
        grow_rules: TreeGrowRules
        max_features: float
        max_depth: int
        min_samples_split: int
    NodeWithData = tuple[n: Node, X: seq[seq[float]], y: seq[float]]

proc new_tree (task: Task, max_depth, min_samples_split: int, max_features: float): DecisionTree =
    result = new(DecisionTree)
    result.grow_rules = new_tree_grow_rules()
    result.root = new_root(task, tree_rules=result.grow_rules)
    if max_depth != -1:
        result.grow_rules.stop_rules.add_creation_rule max_depth_rule(max_depth)
    if min_samples_split != -1:
        result.grow_rules.stop_rules.add_pre_split_rule min_samples_split_rule(min_samples_split)
    result.grow_rules.stop_rules.add_creation_rule unique_class_rule()
    result.grow_rules.stop_rules.add_creation_rule impurity_rule(0.01)
    result.max_features = max_features


proc new_classification_tree* (max_depth: int = -1, min_samples_split: int = 1, max_features: float = 1.0): DecisionTree = 
    new_tree(task=Classification, max_depth, min_samples_split, max_features) 

proc new_regression_tree* (max_depth: int = -1, min_samples_split: int = 1, max_features: float = 1.0): DecisionTree = 
    new_tree(task=Regression, max_depth, min_samples_split, max_features)

proc fit* (t: DecisionTree, X: seq[seq[float]], y: seq[float]) =
    assert X.len == y.len
    var border= new_seq[NodeWithData](1)
    border[0] = (t.root, X, y)
    while border.len > 0:
        let (node, X_data, y_data) = border.pop()
        let sons = node.generate_sons(X_data, y_data)
        if not(sons.first of Leaf):
            border.add((sons.first, sons.X1, sons.y1))
        if not(sons.second of Leaf):
            border.add((sons.second, sons.X2, sons.y2))

proc print_root_split*(t: DecisionTree) =
    echo "Split in column ", t.root.split_column, " with value ", t.root.split_value
            
proc predict*(tree: DecisionTree, x: seq[float]): float =
    tree.root.get_value(x)

proc predict*(tree: DecisionTree, X: seq[seq[float]]): seq[float] =
    X.map_it(tree.predict(it))