import random
import ../view
import ../utils

type Xy* = tuple[X: MatrixView[float32], y: VectorView[float32]]

proc bagging*(X: sink seq[seq[float32]], y: sink seq[float32], perc_bagging:float32): Xy =
    let b_index = sample_wo_reins(0, y.len-1, perc_bagging)
    return (new_matrix_view(X, b_index), new_vector_view(y, b_index))