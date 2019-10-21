import ../utils
import math
import neo
import ../matrix_view
import sequtils
type Xy* {.shallow.} = tuple[X: MatrixView[float], y: VectorView[float]]

proc bagging*(X: Matrix[float], y: Vector[float], perc_bagging:float): Xy =
    let init_len = (y.len.float * perc_bagging).ceil.int
    let ixs_keep = generate_random_sequence(X.M - 1, init_len)
    let X_bagged = new_matrix_view(X, ixs_keep)
    let y_bagged = new_vector_view(y, ixs_keep)
    return (X_bagged, y_bagged)