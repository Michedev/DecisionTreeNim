import tree_rules
import ../node/inode

proc min_samples_split_rule*(min_samples_split: int): Rule =
    (proc(n: INode, X: seq[seq[float]], y: seq[float]): bool = len(X) <= min_samples_split)

proc max_depth_rule*(max_depth: int): Rule =
    (proc(n: INode, X: seq[seq[float]], y: seq[float]): bool = n.level > max_depth)

proc unique_class_rule*(): Rule =
    (proc(n: INode, X: seq[seq[float]], y: seq[float]): bool =
        let first_el = y[0]
        for el in y:
            if el != first_el:
                return false
        return true)

proc impurity_rule*(threshold: float): Rule =
    (proc(n: INode, X: seq[seq[float]], y: seq[float]): bool =
        let imp = n.impurity_f(y)
        echo "Impurity: ", imp
        return imp < threshold)
