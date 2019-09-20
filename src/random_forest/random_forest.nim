import ../tree
import ../task
import sequtils
import tables
import random
import stats
import pure.concurrency.threadpool
import sequtils2

type RandomForest* = ref object
    trees: seq[DecisionTree]
    trees_task: Task
    bagging: float
    num_classes: int
    num_threads: int

proc num_trees*(forest: RandomForest): Natural =
    forest.trees.len

proc new_random_forest*(trees_task: Task, n_trees, num_threads: int, bagging: float): RandomForest =
    result = new(RandomForest)
    result.bagging = bagging
    result.num_threads = num_threads
    result.trees = newSeq[DecisionTree](n_trees)

proc new_random_forest(trees: seq[DecisionTree]): RandomForest =
    result = new(RandomForest)
    result.trees = trees


proc new_random_forest_classifier*(n_trees: int = 100, num_threads: int = 4, bagging: float = 1.0): RandomForest =
    new_random_forest(Classification, n_trees, num_threads, bagging)

proc fit* (rf: RandomForest, X: seq[seq[float]], y: seq[float]) =
    rf.num_classes = y.uniques[float](preserve_order=false).len
    for i in 0..<rf.num_trees:
        case rf.trees_task:
            of Classification:
                rf.trees[i] = new_classification_tree()
            of Regression:
                rf.trees[i] = new_regression_tree()
    for tree in rf.trees:
        tree.fit(X, y)
    
proc predict*(rf: RandomForest, x: seq[float]): float =
    let predictions = rf.trees.map_it(it.predict(x))
    case rf.trees_task:
        of Classification:
            return predictions.toCountTable().largest.key
        of Regression:
            return predictions.mean()

proc predict*(rf: RandomForest, X: seq[seq[float]]): seq[float] =
    X.map_it(rf.predict(it))

proc predict_proba_parallel(forest: RandomForest, x: seq[float], predict_proba: proc(f: RandomForest, x: seq[float]): seq[float]): seq[float] =
    let trees_per_thread: int = (forest.num_trees.float / forest.num_threads.float).int
    result = new_seq[float](forest.num_classes)
    var flowvars = new_seq[FlowVar[seq[float]]](forest.num_threads)
    for i_thread in 1..forest.num_threads:
        let trees_slice = if(i_thread < forest.num_threads):
                (i_thread * trees_per_thread)..<((i_thread+1) * trees_per_thread)
            else: (i_thread*trees_per_thread)..<forest.trees.len
        let subtrees = forest.trees[trees_slice]
        let subforest = new_random_forest(subtrees)
        subforest.num_classes = forest.num_classes
        subforest.num_threads = 1
        flowvars[i_thread - 1] = spawn predict_proba(subforest, x)
    for flowvar in flowvars:
        let p_subtrees = ^flowvar
        for i in 0..<forest.num_classes:
            result[i] += p_subtrees[i]
    for i in 0..<forest.num_classes:
        result[i] / forest.num_threads
    
proc predict_proba*(forest: RandomForest, x: seq[float]): seq[float] =
    if forest.num_threads > 1:
        return forest.predict_proba_parallel(x, predict_proba)
    result = new_seq[float](forest.num_classes)
    for t in forest.trees:
        let p_y =t.predict_proba(x)
        for i_class in 0..<forest.num_classes:
            result[i_class] += p_y[i_class]
    for i_class in 0..<forest.num_classes:
        result[i_class] /= forest.num_trees.float

proc predict_proba*(forest: RandomForest, X: seq[seq[float]]): seq[seq[float]] =
    X.mapIt(forest.predict_proba(it))
