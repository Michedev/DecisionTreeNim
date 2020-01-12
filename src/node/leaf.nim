import ../task
import node
import stats
import tables
import ../view


proc get_leaf_func*(n: Node, X: MatrixView[float32], y: VectorView[float32]) : proc(x: sink seq[float32]): float32 {.gcsafe.} =
    if n.tree_task == Classification:
        var ctable = toCountTable y.to_seq()
        let mode: float32 = ctable.largest.key
        return proc(x: seq[float32]): float32 {.gcsafe.} = mode
    else:
        let m = y.to_seq.mean()
        return proc(x: seq[float32]): float32 {.gcsafe.} = m

#TODO export and add field on leaf type
# proc get_leaf_proba_func*(n: Node, X: MatrixView[float32], y: VectorView[float32]) : proc(x: VectorView[float32]): VectorView[float32] {.gcsafe.} =
#     if n.tree_task == Classification:
#         var count_table = toCountTable y
#         var probs = new_VectorView[float32](count_table.len)
#         var i = 0
#         for k, freq in mpairs(count_table):
#             probs[i] = freq / y.len
#             inc i
#         return proc(x: VectorView[float32]): VectorView[float32] {.gcsafe.} = probs
#     elif n.tree_task == Regression:
#         raise newException(Exception, "Cannot estimate probability in a regression tree")
