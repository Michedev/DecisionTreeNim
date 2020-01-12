import tree_rules
import ../train/splitresult
import ../node/inode
import ../view

proc min_samples_split_rule*(min_samples_split: int): Rule =
    (proc(n: INode, X: MatrixView[float32], y: VectorView[float32]): bool {.gcsafe.} = len(X) <= min_samples_split)

proc max_depth_rule*(max_depth: int): Rule =
    (proc(n: INode, X: MatrixView[float32], y: VectorView[float32]): bool {.gcsafe.} = n.level > max_depth)

proc unique_class_rule*(): Rule =
    proc is_unique_class(n: INode, X: MatrixView[float32], y: VectorView[float32]): bool {.gcsafe.} =
        if y.len == 0:
            return true
        let first_el = y[0]
        for el in y:
            if el != first_el:
                return false
        return true
    return is_unique_class

proc min_impurity_decrease_rule*(threshold: float32): PostSplitRule =
    proc is_impurity_less(n: INode, X: MatrixView[float32], y: VectorView[float32], X1: MatrixView[float32], y1: VectorView[float32], X2: MatrixView[float32], y2: VectorView[float32], split: SplitResult): bool {.gcsafe.} =
        ## Stop if the decrease of split impurity is less than threshold
        let perc_1 = X1.len.float32 / X.len.float32
        let perc_2 = X2.len.float32 / X.len.float32

        let decrease = n.impurity_value - (perc_1 * split.impurity_1 + perc_2 * split.impurity_2)
        return decrease < threshold        
    return is_impurity_less