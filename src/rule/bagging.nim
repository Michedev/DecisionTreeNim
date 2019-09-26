import random

type Xy* = tuple[X: seq[seq[float]], y: seq[float]]

proc bagging*(X: seq[seq[float]], y: seq[float], perc_bagging:float): Xy =
    var 
        X_bagged: seq[seq[float]] = new_seq[seq[float]]((X.len.float * perc_bagging).int)
        y_bagged: seq[float] = new_seq[float]((y.len.float * perc_bagging).int)
    var ixs_keep = new_seq[int](0)
    for i in 0||(X_bagged.len-1):
        randomize()
        if rand(1.0) <= perc_bagging:
            ixs_keep.add i
    var i_new_train = 0
    for ix_keep in ixs_keep:
        if i_new_train >= X_bagged.len:
            X_bagged.add X[ix_keep]
            y_bagged.add y[ix_keep]
        else:
            X_bagged[i_new_train] = X[ix_keep]
            y_bagged[i_new_train] = y[ix_keep]
            inc i_new_train