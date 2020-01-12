import ../node/node, ../node/constructors, ../node/leaf
import split, stop, splitresult
import typetraits
import ../rule/tree_rules
import options
import ../view

type Sons = tuple[first, second: Node, X1, X2: MatrixView[float32], y1, y2: VectorView[float32]]

proc generate_sons*(n: Node, X: MatrixView[float32], y: VectorView[float32]): Option[Sons] {.gcsafe.} =
    let split: SplitResult = best_split(n.tree_task, n.impurity_f, X, y, n.max_features)
    # echo "Split on ", split.col, " with value ",  split.split_value
    # echo "tot split value: ", split.impurity, " and single values " , split.impurity_1, " - ", split.impurity_2
    n.split_column = split.col
    n.split_value  = split.split_value
    let
        x1_len = split.index[0].len
        x2_len = split.index[1].len
    var 
        X1 = new_matrix_view(X, split.index[0])
        y1 = new_vector_view(y, split.index[0])
        X2 = new_matrix_view(X, split.index[1])
        y2 = new_vector_view(y, split.index[1])
    if n.stop_rules.on_post_split(n, X, y, X1, y1, X2, y2, split):
        # echo "Split block on depth ", n.level
        return options.none[Sons]()     
    
    if n.stop_rules.on_creation(n, X1, y1):
        n.sons[0] = new_leaf(n, X1, y1)
    else:
        n.sons[0] = new_son(n)
    if n.stop_rules.on_creation(n, X2, y2):
        n.sons[1] = new_leaf(n, X2, y2)
    else:
        n.sons[1] = new_son(n)
    n.sons[0].impurity_value = split.impurity_1
    n.sons[1].impurity_value = split.impurity_2

    return some((n.sons[0], n.sons[1], X1, X2, y1, y2))