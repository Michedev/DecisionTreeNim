import ../node/node, ../node/constructors, ../node/leaf
import split, splitresult
import typetraits
import ../rule/tree_rules
import options

type Sons = tuple[first, second: Node, X1, X2: seq[seq[float]], y1, y2: seq[float]]

proc generate_sons*(n: Node, X: seq[seq[float]], y: seq[float]): Option[Sons] {.gcsafe.} =
    let split: SplitResult = best_split(n.impurity, X, y, n.max_features)
    if split.impurity == Inf:
        return options.none[Sons]()
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
    if n.stop_rules.on_post_split(n, X, y, X1, y1, X2, y2):
        # echo "Split negated on depth ", n.level
        return options.none[Sons]()     
    for i_indx, indx in split.index[0]:
        X1[i_indx] = X[indx]
        y1[i_indx] = y[indx]
    for i_indx, indx in split.index[1]:
        X2[i_indx] = X[indx]
        y2[i_indx] = y[indx]
    
    if n.stop_rules.on_creation(n, X1, y1):
        # echo"create new leaf for son number ", i+1
        n.sons[0] = new_leaf(n, X1, y1)
        # echo"y leaf: ", y_splitted[i]
    else:
        # echo"create new node for son number ", i+1
        n.sons[0] = new_son(n)
    if n.stop_rules.on_creation(n, X2, y2):
        # echo"create new leaf for son number ", i+1
        n.sons[1] = new_leaf(n, X2, y2)
        # echo"y leaf: ", y_splitted[i]
    else:
        # echo"create new node for son number ", i+1
        n.sons[1] = new_son(n)

    return some((n.sons[0], n.sons[1], X1, X2, y1, y2))