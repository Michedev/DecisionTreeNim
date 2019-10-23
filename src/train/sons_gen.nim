import ../node/node, ../node/constructors, ../node/leaf
import split, splitresult
import typetraits
import ../rule/tree_rules
import options
import neo
import ../matrix_view
import ../matrix_view_sorted


type Sons {.shallow.} = tuple[first, second: Node, X1, X2: MatrixViewSorted[float], y1, y2: VectorView[float]]

proc generate_sons*(n: Node, X: MatrixViewSorted[float], y: VectorView[float]): Option[Sons] {.gcsafe.} =
    # # echo "========================================================================================================"
    # # echo "level ", n.level
    let split: SplitResult = best_split(n.impurity, X, y, n.max_features)
    # # echo "split.impurity: ", split.impurity
    if split.impurity == Inf:
        return options.none[Sons]()
    n.split_column = split.col
    n.split_value  = split.split_value
    let
        x1_len = split.i1.len
        x2_len = split.i2.len 
        X1 = new_matrix_view_sorted(X, split.i1, X.col_index)
        y1 = new_vector_view(y, split.i1)
        X2 = new_matrix_view_sorted(X, split.i2, X.col_index)
        y2 = new_vector_view(y, split.i2)
    if n.stop_rules.on_post_split(n, X, y, X1, y1, X2, y2):
        # # echo "Split negated on depth ", n.level
        return options.none[Sons]()     
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