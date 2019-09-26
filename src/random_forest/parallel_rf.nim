
# Old parallel_predict function with generics that didn't work
# proc predict_parallel[R: (float|seq[float])](forest: RandomForest, x: seq[float], single_predict: proc(f: RandomForest, x: seq[float]): R {.gcsafe.}): R =
#     let trees_per_thread: int = (forest.num_trees.float / forest.num_threads.float).int
#     when R is seq[float]:   
#         result = new_seq[float](forest.num_classes)
#     else:
#         var results = new_seq[float](0)
#     var thread_results = new_seq[FlowVar[R]](forest.num_threads)
#     for i_thread in 1..forest.num_threads:
#         let trees_slice = if(i_thread < forest.num_threads):
#                 (i_thread * trees_per_thread)..<((i_thread+1) * trees_per_thread)
#             else: (i_thread*trees_per_thread)..<forest.trees.len
#         let subtrees = forest.trees[trees_slice]
#         let subforest = new_random_forest(subtrees)
#         subforest.num_classes = forest.num_classes
#         subforest.num_threads = 1
#         subforest.task = forest.task
#         thread_results[i_thread - 1] = spawn single_predict(subforest, x)
#     for thread_result in thread_results:
#         let p_subtrees = ^thread_result
#         when R is seq[float]:
#             for i in 0..<forest.num_classes:
#                 result[i] += p_subtrees[i]
#         else:
#             results.add p_subtrees
#     when R is seq[float]:
#         for i in 0..<forest.num_classes:
#             result[i] /= forest.num_threads.float
#     else:
#         case forest.task:
#             of Classification:
#                 return results.toCountTable().largest.key
#             of Regression:
#                 return results.mean()


#for parallel use only
proc fit(forest: seq[DecisionTree], X: seq[seq[float]], y: seq[float]): void=
    for tree in forest:
        tree.fit(X,y)

proc fit_parallel*(forest: RandomForest, X: seq[seq[float]], y: seq[float]) =
    let trees_per_thread: int = (forest.num_trees.float / forest.num_threads.float).int
    var thread_results = new_seq[bool](forest.num_threads)
    for i_thread in 0||(forest.num_threads-1):
        let trees_slice = if(i_thread < forest.num_threads-1):
            (i_thread * trees_per_thread)..<((i_thread+1) * trees_per_thread)
        else: (i_thread*trees_per_thread)..<forest.trees.len
        fit(forest.trees[trees_slice], X, y)
    
proc predict_proba_parallel*(forest: RandomForest, x: seq[float], single_predict: proc(f: RandomForest, x: seq[float]): seq[float] {.gcsafe.}): seq[float] =
    let trees_per_thread: int = (forest.num_trees.float / forest.num_threads.float).int
    result = new_seq[float](forest.num_classes)
    var thread_results = new_seq[seq[float]](forest.num_threads)
    for i_thread in 0..(forest.num_threads-1):
        let trees_slice = if(i_thread < (forest.num_threads-1)):
                (i_thread * trees_per_thread)..<((i_thread+1) * trees_per_thread)
            else: (i_thread*trees_per_thread)..<forest.trees.len
        let subtrees = forest.trees[trees_slice]
        let subforest = new_random_forest(subtrees)
        subforest.num_classes = forest.num_classes
        subforest.num_threads = 1
        subforest.task = forest.task
        thread_results[i_thread] = single_predict(subforest, x)
    for thread_result in thread_results:
        let p_subtrees = thread_result
        for i in 0..<forest.num_classes:
            result[i] += p_subtrees[i]
    for i in 0..<forest.num_classes:
        result[i] /= forest.num_threads.float



proc predict_parallel*(forest: RandomForest, x: seq[float], single_predict: proc(f: RandomForest, x: seq[float]): float {.gcsafe.}): float =
    let trees_per_thread: int = (forest.num_trees.float / forest.num_threads.float).int
    var results = new_seq[float](0)
    var thread_results = new_seq[float](forest.num_threads)
    for i_thread in 0||(forest.num_threads-1):
        let trees_slice = if(i_thread < (forest.num_threads-1)):
                (i_thread * trees_per_thread)..<((i_thread+1) * trees_per_thread)
            else: (i_thread*trees_per_thread)..<forest.trees.len
        let subtrees = forest.trees[trees_slice]
        let subforest = new_random_forest(subtrees)
        subforest.num_classes = forest.num_classes
        subforest.num_threads = 1
        subforest.task = forest.task
        thread_results[i_thread] = single_predict(subforest, x)
        results.add thread_results[i_thread]
    case forest.task:
        of Classification:
            return results.toCountTable().largest.key
        of Regression:
            return results.mean()
