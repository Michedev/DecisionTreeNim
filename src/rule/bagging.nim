import random
import ../view
import ../utils

type Xy* = tuple[X: MatrixView[float], y: VectorView[float]]

proc bagging*(X: seq[seq[float]], y: seq[float], perc_bagging:float): Xy =
    let b_index = sample_wo_reins(0, y.len-1, perc_bagging)
    return (new_matrix_view(X, b_index), new_vector_view(y, b_index))