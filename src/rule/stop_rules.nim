import tree_rules
import ../train/splitresult
import ../node/inode
import ../view

proc min_samples_split_rule*(min_samples_split: int): Rule =
    (proc(n: INode, X: MatrixView[float], y: VectorView[float]): bool {.gcsafe.} = len(X) <= min_samples_split)

proc max_depth_rule*(max_depth: int): Rule =
    (proc(n: INode, X: MatrixView[float], y: VectorView[float]): bool {.gcsafe.} = n.level > max_depth)

proc unique_class_rule*(): Rule =
    (proc(n: INode, X: MatrixView[float], y: VectorView[float]): bool {.gcsafe.} =
        let first_el = y[0]
        for el in y:
            if el != first_el:
                return false
        return true)

proc min_impurity_decrease_rule*(threshold: float): PostSplitRule =
    (
        proc(n: INode, X: MatrixView[float], y: VectorView[float], X1: MatrixView[float], y1: VectorView[float], X2: MatrixView[float], y2: VectorView[float]): bool {.gcsafe.} =
            # let decrease = n.impurity_f(y.to_seq) - (n.impurity_f(y1.to_seq) + n.impurity_f(y2.to_seq)) 
            # # echo"decrease is ", decrease 
            # return decrease < threshold
            return false
        
    )