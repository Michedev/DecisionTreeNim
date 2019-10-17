import tree_rules
import ../train/splitresult
import ../node/inode

proc min_samples_split_rule*(min_samples_split: int): Rule =
    proc min_samples_split_f(n: INode, X: seq[seq[float]], y: seq[float]): bool {.gcsafe.} = 
        len(X) <= min_samples_split
    return min_samples_split_f

proc max_depth_rule*(max_depth: int): Rule =
    proc max_depth_f(n: INode, X: seq[seq[float]], y: seq[float]): bool {.gcsafe.} =
         n.level > max_depth
    max_depth_f

proc unique_class_rule*(): Rule =
    proc unique_class_f(n: INode, X: seq[seq[float]], y: seq[float]): bool {.gcsafe.} =
        let first_el = y[0]
        for el in y:
            if el != first_el:
                return false
        return true
    return unique_class_f

proc min_impurity_decrease_rule*(threshold: float): PostSplitRule =
    proc min_impurity_decrease_f(n: INode, X: seq[seq[float]], y: seq[float], X1: seq[seq[float]], y1: seq[float], X2: seq[seq[float]], y2: seq[float]): bool {.gcsafe.} =
            let decrease = n.impurity_f(y) - (n.impurity_f(y1) + n.impurity_f(y2)) 
            # echo"decrease is ", decrease 
            return decrease < threshold
    return min_impurity_decrease_f    
    