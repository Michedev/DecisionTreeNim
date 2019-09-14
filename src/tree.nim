import node/[node, constructors, traverse]
import train/[split, sons_gen, train]
import task
import typetraits
import core.typeinfo
import math
import sequtils
import options
import rule/[tree_rules, stop_rules]

type 
    DecisionTree*  = ref object
        root: Node
        grow_rules: TreeGrowRules
        max_features: float
        max_depth: int
        min_samples_split: int

proc new_tree (task: Task, max_depth, min_samples_split: int, max_features: float): DecisionTree =
    result = new(DecisionTree)
    result.grow_rules = new_tree_grow_rules()
    result.root = new_root(task, tree_rules=result.grow_rules)
    if max_depth != -1:
        result.grow_rules.stop_rules.add_creation_rule max_depth_rule(max_depth)
    if min_samples_split != -1:
        result.grow_rules.stop_rules.add_pre_split_rule min_samples_split_rule(min_samples_split)
    result.grow_rules.stop_rules.add_creation_rule unique_class_rule()
    result.grow_rules.stop_rules.add_post_split_rule min_impurity_decrease(0.0001)
    result.max_features = max_features


proc new_classification_tree* (max_depth: int = -1, min_samples_split: int = -1, max_features: float = 1.0): DecisionTree = 
    new_tree(task=Classification, max_depth, min_samples_split, max_features) 

proc new_regression_tree* (max_depth: int = -1, min_samples_split: int = 1, max_features: float = 1.0): DecisionTree = 
    new_tree(task=Regression, max_depth, min_samples_split, max_features)

## Train function of decision tree
proc fit* (t: DecisionTree, X: seq[seq[float]], y: seq[float]) =
    try:
        fit(t.root, X, y)
    except RootIsLeaf:
        t.root = new_root_leaf(X,y)

proc print_root_split*(t: DecisionTree) =
    if t.root of Leaf:
        echo "Root is a leaf"
    else:
        echo "Root node, split in column ", t.root.split_column, " with value ", t.root.split_value
            
proc predict*(tree: DecisionTree, x: seq[float]): float =
    tree.root.get_value(x)

proc predict*(tree: DecisionTree, X: seq[seq[float]]): seq[float] =
    X.map_it(tree.predict(it))

proc predict_proba*(tree: DecisionTree, x: seq[float]): seq[float] =
    tree.root.get_proba(x)

proc predict_proba*(tree: DecisionTree, X: seq[seq[float]]): seq[seq[float]] =
    X.map_it(tree.predict_proba(it))