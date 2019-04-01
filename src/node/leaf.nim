import ../task
import node
import stats
import tables

proc get_leaf_func*(n: Node, X: seq[seq[float]], y: seq[float]): proc(x: seq[float]): float =
    if n.task == Classification:
        let mode = y.toCountTable().largest.key
        return proc(x: seq[float]): float = mode
    else:
        let m = y.mean()
        return proc(x: seq[float]): float = m
