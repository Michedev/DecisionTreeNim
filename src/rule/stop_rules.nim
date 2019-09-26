import tree_rules
import ../train/splitresult
import ../node/inode

proc min_samples_split_rule*(min_samples_split: int): Rule =
    (proc(n: INode, X: seq[seq[float]], y: seq[float]): bool {.gcsafe.} = len(X) <= min_samples_split)

proc max_depth_rule*(max_depth: int): Rule =
    (proc(n: INode, X: seq[seq[float]], y: seq[float]): bool {.gcsafe.} = n.level > max_depth)

proc unique_class_rule*(): Rule =
    (proc(n: INode, X: seq[seq[float]], y: seq[float]): bool {.gcsafe.} =
        let first_el = y[0]
        for el in y:
            if el != first_el:
                return false
        return true)

proc min_impurity_decrease*(threshold: float): PostSplitRule =
    (
        proc(n: INode, X: seq[seq[float]], y: seq[float], X1: seq[seq[float]], y1: seq[float], X2: seq[seq[float]], y2: seq[float]): bool {.gcsafe.} =
            let decrease = n.impurity_f(y) - (n.impurity_f(y1) + n.impurity_f(y2)) 
            echo "decrease is ", decrease 
            return decrease < threshold
        
    )