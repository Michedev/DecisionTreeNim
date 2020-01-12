import sequtils
import threadpool

#for parallel use only
proc tree_fit(tree: DecisionTree, X: ptr seq[seq[float32]], y: ptr seq[float32]): DecisionTree {.thread.} =
    tree.fit(X[], y[])
    return tree

proc fit_parallel*(forest: RandomForest, X: seq[seq[float32]], y: seq[float32]) =
    let trees_per_thread: int = (forest.num_trees.float32 / forest.num_threads.float32).int
    echo "trees per thread: ", trees_per_thread
    var threads = newSeq[FlowVar[DecisionTree]](forest.num_trees)
    let X_addr = unsafeAddr(X)
    let y_addr = unsafeAddr(y)
    for i, tree in forest.trees:
        threads[i] = spawn(tree_fit(tree, X_addr, y_addr))
    for i in 0..<forest.num_trees:
        forest.trees[i] = ^threads[i]