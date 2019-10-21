import ../task
import node
import stats
import tables
import neo
import ../utils
import ../matrix_view

proc get_leaf_func*(n: Node, X: MatrixView[float], y: VectorView[float]) : proc(x: Vector[float]): float {.gcsafe.} =
    let y_vector: Vector[float] = y.to_vector()
    if n.tree_task == Classification:
        var ctable = y_vector.toCountTable()
        let mode: float = ctable.largest[0]
        return proc(x: Vector[float]): float {.gcsafe.} = mode
    else:
        let m = y_vector.mean()
        return proc(x: Vector[float]): float {.gcsafe.} = m

#TODO export and add field on leaf type
proc get_leaf_proba_func*(n: Node, X: MatrixView[float], y: VectorView[float]) : proc(x: Vector[float]): Vector[float] {.gcsafe.} =
    let y_vector: Vector[float] = y.to_vector()
    if n.tree_task == Classification:
        var count_table = toCountTable y_vector
        var probs = zeros(count_table.len)
        var i = 0
        for k, freq in mpairs(count_table):
            probs[i] = freq / y.len
            inc i
        return proc(x: Vector[float]): Vector[float] {.gcsafe.} = probs
    elif n.tree_task == Regression:
        raise newException(Exception, "Cannot estimate probability in a regression tree")
