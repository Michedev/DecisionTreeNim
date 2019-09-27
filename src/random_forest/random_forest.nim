import ../tree
import ../task
import sequtils
import tables
import random
import stats
import sequtils2

type RandomForest* = ref object
    trees: seq[DecisionTree]
    task: Task
    bagging*: float
    max_features*: float
    num_classes*: int
    num_threads*: int

proc num_trees*(forest: RandomForest): Natural =
    forest.trees.len
    

proc new_random_forest*(task: Task, n_trees, num_threads: int, bagging: float, max_features: float): RandomForest =
    result = new(RandomForest)
    result.bagging = bagging
    result.num_threads = num_threads
    result.max_features = max_features
    result.trees = newSeq[DecisionTree](n_trees)

proc new_random_forest(trees: seq[DecisionTree]): RandomForest =
    result = new(RandomForest)
    result.trees = trees


proc new_random_forest_classifier*(n_trees: int = 100, num_threads: int = 1, bagging: float = 0.8, max_features: float = 1.0): RandomForest =
    new_random_forest(Classification, n_trees, num_threads, bagging, max_features)

proc new_random_forest_regressor*(n_trees: int = 100, num_threads: int = 1, bagging: float = 0.8, max_features: float = 1.0): RandomForest =
    new_random_forest(Regression, n_trees, num_threads, bagging, max_features)

include parallel_rf
                
proc fit* (rf: RandomForest, X: seq[seq[float]], y: seq[float]) =
    rf.num_classes = y.uniques(preserve_order=false).len
    for i in 0..<rf.num_trees:
        case rf.task:
            of Classification:
                rf.trees[i] = new_classification_tree()
            of Regression:
                rf.trees[i] = new_regression_tree()
    if rf.num_threads > 1:
        rf.fit_parallel(X,y)
    else:
        for tree in rf.trees:
            tree.fit(X, y)
    
                
    
proc predict_row*(rf: RandomForest, x: seq[float]): float {.gcsafe.} =
    if rf.num_threads > 1:
        return rf.predict_parallel(x, predict_row)
    let predictions = rf.trees.map_it(it.predict(x))
    case rf.task:
        of Classification:
            return predictions.toCountTable().largest.key
        of Regression:
            return predictions.mean()

proc predict*(rf: RandomForest, x: seq[float]): float =
    rf.predict_row(x);
            

proc predict*(rf: RandomForest, X: seq[seq[float]]): seq[float] {.gcsafe.} =
    X.map_it(rf.predict_row(it))
    
proc predict_proba_row*(forest: RandomForest, x: seq[float]): seq[float] {.gcsafe.} =
    if forest.num_threads > 1:
        return forest.predict_proba_parallel(x, predict_proba_row)
    result = new_seq[float](forest.num_classes)
    for t in forest.trees:
        let p_y = t.predict_proba(x)
        for i_class in 0..<forest.num_classes:
            result[i_class] += p_y[i_class]
    for i_class in 0..<forest.num_classes:
        result[i_class] /= forest.num_trees.float

proc predict_proba*(forest: RandomForest, X: seq[seq[float]]): seq[seq[float]]  =
    X.mapIt(forest.predict_proba_row(it))
