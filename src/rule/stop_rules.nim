import tree_rules
import ../train/splitresult
import ../node/inode
import neo
import ../matrix_view
import ../matrix_view_sorted
#todo set matrix like generic

proc min_samples_split_rule*(min_samples_split: int): Rule =
    proc min_samples_split_f(n: INode, X: MatrixViewSorted[float], y: VectorView[float]): bool {.gcsafe.} = 
        X.M <= min_samples_split
    return min_samples_split_f

proc max_depth_rule*(max_depth: int): Rule =
    proc max_depth_f(n: INode, X: MatrixViewSorted[float], y: VectorView[float]): bool {.gcsafe.} =
        return n.level > max_depth
    max_depth_f

proc unique_class_rule*(): Rule =
    proc unique_class_f(n: INode, X: MatrixViewSorted[float], y: VectorView[float]): bool {.gcsafe.} =
        let first_el = y[0]
        for el in y:
            if el != first_el:
                return false
        return true
    return unique_class_f


# ##TODO FIX IT!
# proc min_impurity_decrease_rule*(threshold: float): PostSplitRule =
#     proc min_impurity_decrease_f(n: INode, X: MatrixViewSorted[float], y: VectorView[float], X1: MatrixViewSorted[float], y1: VectorView[float], X2: MatrixViewSorted[float], y2: VectorView[float]): bool {.gcsafe.} =
#             let decrease = n.impurity_f(y) - (n.impurity_f(y1) + n.impurity_f(y2)) 
#             # echo"decrease is ", decrease 
#             return decrease < threshold
#     return min_impurity_decrease_f    
    