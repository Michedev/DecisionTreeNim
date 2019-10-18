import ../utils
import math
type Xy* = tuple[X: seq[seq[float]], y: seq[float]]

proc bagging*(X: seq[seq[float]], y: seq[float], perc_bagging:float): Xy =
    var 
        init_len = (y.len.float * perc_bagging).ceil.int
        X_bagged: seq[seq[float]] = new_seq[seq[float]](init_len)
        y_bagged: seq[float] = new_seq[float](init_len)
    var ixs_keep = generate_random_sequence(X.len - 1, init_len)
    var i_new_train = 0
    for ix_keep in ixs_keep:
        X_bagged[i_new_train] = X[ix_keep]
        y_bagged[i_new_train] = y[ix_keep]
        inc i_new_train
    return (X_bagged, y_bagged)