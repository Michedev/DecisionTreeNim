import ../task
import node
import tables
import math
import ../view


proc get_leaf_func*(n: Node, X: MatrixView[float32], y: VectorView[float32]) : auto {.gcsafe.} =
    if n.tree_task == Classification:
        var ctable = toCountTable y.to_seq()
        let mode: float32 = ctable.largest.key
        return proc(x: seq[float32]): float32 {.gcsafe.} = mode
    else:
        var tot: float32 = 0.0
        for v in y:
            tot += v
        let m: float32 = tot / y.len.float32
        return proc(x: seq[float32]): float32 {.gcsafe.} = m

#TODO export and add field on leaf type
proc get_leaf_proba_func*(n: Node, X: MatrixView[float32], y: VectorView[float32]) : auto {.gcsafe.} =
    if n.tree_task == Classification:
        var count_table = toCountTable y.to_seq
        var probs = newSeq[float32](count_table.len)
        var i = 0
        for (k, freq) in mpairs(count_table):
            probs[i] = freq / y.len
            inc i
        return proc(x: seq[float32]): seq[float32] {.gcsafe.} = probs
    elif n.tree_task == Regression:
        raise newException(Exception, "Cannot estimate probability in a regression tree")
