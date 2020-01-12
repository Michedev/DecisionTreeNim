import ../tree
import ../task
import sequtils
import tables
import random
import stats
import sequtils2
import ../utils
import ../hyperparams

type RandomForest* = ref object
    trees: seq[DecisionTree]
    task: Task
    hyperparams: Hyperparams
    num_classes*: int
    num_threads*: int

proc num_trees*(forest: RandomForest): Natural =
    forest.trees.len
    

proc new_random_forest*(task: Task, n_trees, num_threads: int, h: Hyperparams): RandomForest =
    result = new(RandomForest)
    result.hyperparams = h
    result.trees = newSeq[DecisionTree](n_trees)
    result.num_threads = num_threads

proc new_random_forest(trees: seq[DecisionTree]): RandomForest =
    result = new(RandomForest)
    result.trees = trees

hyperparams_binding(RandomForest)


proc new_random_forest_classifier*(n_trees: int = 100, max_depth: int = -1, min_samples_split: int = -1,
                                   max_features: float32 = 0.7, min_impurity_decrease: float32 = 1e-6,
                                   bagging: float32 = 0.7, num_threads: int = 1,): RandomForest =
    new_random_forest(Classification, n_trees=n_trees, num_threads=num_threads, h=(max_depth, min_samples_split, max_features, min_impurity_decrease, bagging))

proc new_random_forest_regressor*(n_trees: int = 100, max_depth: int = -1, min_samples_split: int = -1,
                                  max_features: float32 = 0.7, min_impurity_decrease: float32 = 1e-6,
                                  bagging: float32 = 0.7, num_threads: int = 1): RandomForest =
    new_random_forest(Regression, n_trees=n_trees, num_threads=num_threads, h=(max_depth, min_samples_split, max_features, min_impurity_decrease, bagging))

include parallel_rf
                
proc fit* (rf: RandomForest, X: seq[seq[float32]], y: seq[float32]) =
    rf.num_classes = y.uniques(preserve_order=false).len
    for i in 0..<rf.num_trees:
        rf.trees[i] = new_tree(rf.task, rf.hyperparams)
    if rf.num_threads > 1:
        rf.fit_parallel(X,y)
    else:
        for tree in rf.trees:
            tree.fit(X, y)
    
                
    
proc predict*(rf: RandomForest, x: sink seq[float32]): float32 {.gcsafe.} =
    let predictions = rf.trees.map_it(it.predict(x))
    case rf.task:
        of Classification:
            return predictions.toCountTable().largest.key
        of Regression:
            return predictions.mean()

proc predict*(rf: RandomForest, X: sink seq[seq[float32]]): seq[float32] {.gcsafe.} =
    result = new_seq[float32](X.len)
    for i, row in X:
        result[i] = rf.predict(row)
    
proc predict_proba*(forest: RandomForest, x: sink seq[float32]): seq[float32] {.gcsafe.} =
    result = new_seq[float32](forest.num_classes)
    for t in forest.trees:
        let p_y = t.predict_proba(x)
        for i_class in 0..<forest.num_classes:
            result[i_class] += p_y[i_class]
    for i_class in 0..<forest.num_classes:
        result[i_class] /= forest.num_trees.float32

proc predict_proba*(forest: RandomForest, X: sink seq[seq[float32]]): seq[seq[float32]]  =
    result = newSeq[seq[float32]](X.len)
    for i, row in X:
        result[i] = forest.predict_proba(row)