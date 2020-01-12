import tree_rules
import ../train/splitresult
import ../node/inode
import ../view

proc min_samples_split_rule*(min_samples_split: int): Rule =
    (proc(n: INode, X: MatrixView[float32], y: VectorView[float32]): bool {.gcsafe.} = len(X) <= min_samples_split)

proc max_depth_rule*(max_depth: int): Rule =
    (proc(n: INode, X: MatrixView[float32], y: VectorView[float32]): bool {.gcsafe.} = n.level > max_depth)

proc unique_class_rule*(): Rule =
    (proc(n: INode, X: MatrixView[float32], y: VectorView[float32]): bool {.gcsafe.} =
        let first_el = y[0]
        for el in y:
            if el != first_el:
                return false
        return true)

proc min_impurity_decrease_rule*(threshold: float32): PostSplitRule =
    (
        proc(n: INode, X: MatrixView[float32], y: VectorView[float32], X1: MatrixView[float32], y1: VectorView[float32], X2: MatrixView[float32], y2: VectorView[float32]): bool {.gcsafe.} =
            # let decrease = n.impurity_f(y.to_seq) - (n.impurity_f(y1.to_seq) + n.impurity_f(y2.to_seq)) 
            # # echo"decrease is ", decrease 
            # return decrease < threshold
            return false
        
    )