import ../task
import node
import stats
import tables


proc get_leaf_func*(n: Node, X: seq[seq[float]], y: seq[float]) : proc(x: seq[float]): float {.gcsafe.} =
    if n.tree_task == Classification:
        var ctable = toCountTable y
        let mode: float = ctable.largest.key
        return proc(x: seq[float]): float {.gcsafe.} = mode
    else:
        let m = y.mean()
        return proc(x: seq[float]): float {.gcsafe.} = m

#TODO export and add field on leaf type
proc get_leaf_proba_func*(n: Node, X: seq[seq[float]], y: seq[float]) : proc(x: seq[float]): seq[float] {.gcsafe.} =
    if n.tree_task == Classification:
        var count_table = toCountTable y
        var probs = new_seq[float](count_table.len)
        var i = 0
        for k, freq in mpairs(count_table):
            probs[i] = freq / y.len
            inc i
        return proc(x: seq[float]): seq[float] {.gcsafe.} = probs
    elif n.tree_task == Regression:
        raise newException(Exception, "Cannot estimate probability in a regression tree")
