import node, split, constructors, stop, leaf
import typetraits

type Sons = tuple[first, second: Node, X1, X2: seq[seq[float]], y1, y2: seq[float]]

proc generate_sons*(n: Node, X: seq[seq[float]], y: seq[float]): Sons =
    let split: SplitResult = best_split[true](n, X, y)
    let
        x1_len = split.index[0].len
        x2_len = split.index[1].len
    var 
        X1 = new_seq[seq[float]](x1_len)
        y1 = new_seq[float](x1_len)
        X2 = new_seq[seq[float]](x2_len)
        y2 = new_seq[float](x2_len)
        X_splitted = [X1, X2]
        y_splitted = [y1, y2]
    for i in [0,1]:
        for i_indx, indx in split.index[i]:
            X_splitted[i][i_indx] = X[indx]
            y_splitted[i][i_indx] = y[indx]
    for i in [0, 1]:
        if stop.on_creating_new_node(n, X_splitted[i], y_splitted[i]):
            n.sons[i] = new_leaf(n, X_splitted[i], y_splitted[i])
        else:
            n.sons[i] = new_node(n)
    return (n.sons[0], n.sons[1], X_splitted[0], X_splitted[1], y_splitted[0], y_splitted[1])