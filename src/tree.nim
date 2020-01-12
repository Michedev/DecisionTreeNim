import node/[node, constructors, traverse]
import train/[split, sons_gen, train]
import task
import typetraits
import sequtils
import rule/[tree_rules, stop_rules, bagging]
import hyperparams

type 
    DecisionTree*  = ref object
        root: Node
        stop_rules: TreeStopRules
        hyperparams: Hyperparams

proc assert_int_hp(value: int, msg: string = "") =
    assert value == -1 or value > 0, msg

proc assert_0_1_float32_hp(value: float32, msg: string = "") = 
    assert value <= 1.0 or value >= 0.0 or value == -1.0, msg

proc assert_positive_float32_hp(value: float32, msg: string = "") =
    assert value == -1.0 or value > 0.0, msg

hyperparams_binding(DecisionTree)


proc add_rules(tree: DecisionTree, max_depth: int, min_samples_split: int, max_features: float32, min_impurity_decrease: float32) =
    if max_depth != -1:
        tree.stop_rules.add_creation_rule max_depth_rule(max_depth)
    if min_samples_split != -1:
        tree.stop_rules.add_pre_split_rule min_samples_split_rule(min_samples_split)
    if min_impurity_decrease != -1.0:
        tree.stop_rules.add_post_split_rule min_impurity_decrease_rule(min_impurity_decrease)
    tree.stop_rules.add_creation_rule unique_class_rule()


proc new_tree*(task: Task, h: Hyperparams,
               custom_creation_rules: seq[Rule] = @[],
               custom_pre_split_rules: seq[Rule] = @[],
               custom_post_split_rules: seq[PostSplitRule] = @[]): DecisionTree =
    result = new(DecisionTree)
    assert_int_hp(h.max_depth)
    assert_int_hp(h.min_samples_split)
    assert_0_1_float32_hp(h.max_features)
    assert_positive_float32_hp(h.min_impurity_decrease)
    assert_0_1_float32_hp(h.bagging)
    result.stop_rules = new_tree_stop_rules()
    
    result.add_rules(h.max_depth, h.min_samples_split, h.max_features, h.min_impurity_decrease)
    result.root = new_root(task, stop_rules=result.stop_rules)
    result.hyperparams = h


proc new_classification_tree* (max_depth: int = -1, min_samples_split: int = -1, max_features: float32 = 1.0, min_impurity_decrease: float32 = 1e-6,
                               bagging: float32 = 1.0): DecisionTree = 
    new_tree(task=Classification, (max_depth, min_samples_split, max_features, min_impurity_decrease, bagging)) 

proc new_regression_tree* (max_depth: int = -1, min_samples_split: int = -1, max_features: float32 = 1.0, min_impurity_decrease: float32 = 1e-6,
                           bagging: float32 = 1.0): DecisionTree = 
    new_tree(task=Regression, (max_depth, min_samples_split, max_features, min_impurity_decrease, bagging)) 



## Train function of decision tree
proc fit* (t: DecisionTree, X: sink seq[seq[float32]], y: sink seq[float32]) {.gcsafe.} =
    let (X_train, y_train) = bagging(X, y, t.bagging)
    fit(t.root, X_train, y_train)

proc print_root_split(t: DecisionTree) =
    if t.root of Leaf:
        echo "Root is a leaf"
    else:
        echo "Root node, split in column ", t.root.split_column, " with value ", t.root.split_value
            
proc predict*(tree: DecisionTree, x: sink seq[float32]): float32 {.gcsafe.} =
    tree.root.get_value(x)

proc predict*(tree: DecisionTree, X: sink seq[seq[float32]]): seq[float32] {.gcsafe.} =
    result = newSeq[float32](X.len)
    for i, row in X:
        result[i] = tree.predict(row)

proc predict_proba*(tree: DecisionTree, x: seq[float32]): seq[float32] {.gcsafe.} =
    tree.root.get_proba(x)

proc predict_proba*(tree: DecisionTree, X: seq[seq[float32]]): seq[seq[float32]] {.gcsafe.} =
    result = newSeq[seq[float32]](X.len)
    for i, row in X:
        result[i] = tree.predict_proba(row)