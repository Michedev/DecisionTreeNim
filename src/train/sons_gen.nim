import ../node/node, ../node/constructors, ../node/leaf
import split, stop, splitresult
import typetraits
import ../rule/tree_rules
import options

type Sons = tuple[first, second: Node, X1, X2: seq[seq[float]], y1, y2: seq[float]]

proc generate_sons*(n: Node, X: seq[seq[float]], y: seq[float]): Option[Sons] {.gcsafe.} =
    let split: SplitResult = best_split(n.impurity, X, y, n.max_features)
    # echo"Split on ", split.col, " with value ",  split.split_value
    n.split_column = split.col
    n.split_value  = split.split_value
    let
        x1_len = split.index[0].len
        x2_len = split.index[1].len
    var 
        X1 = new_seq[seq[float]](x1_len)
        y1 = new_seq[float](x1_len)
        X2: seq[seq[float]] = new_seq[seq[float]](x2_len)
        y2 = new_seq[float](x2_len)
        X_splitted = [X1, X2]
        y_splitted = [y1, y2]
    if n.stop_rules.on_post_split(n, X, y, X1, y1, X2, y2):
        # echo "Split negated on depth ", n.level
        return options.none[Sons]()     
    for i in [0,1]:
        for i_indx, indx in split.index[i]:
            X_splitted[i][i_indx] = X[indx]
            y_splitted[i][i_indx] = y[indx]
    for i in [0, 1]:
        if n.stop_rules.on_creation(n, X_splitted[i], y_splitted[i]):
            # echo"create new leaf for son number ", i+1
            n.sons[i] = new_leaf(n, X_splitted[i], y_splitted[i])
            # echo"y leaf: ", y_splitted[i]
        else:
            # echo"create new node for son number ", i+1
            n.sons[i] = new_son(n)
    return some((n.sons[0], n.sons[1], X_splitted[0], X_splitted[1], y_splitted[0], y_splitted[1]))