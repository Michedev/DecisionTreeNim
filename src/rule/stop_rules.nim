import tree_rules
import ../node/inode

proc min_samples_split_rule*(min_samples_split: int): Rule =
    (proc(n: INode, X: seq[seq[float]], y: seq[float]): bool = len(X) <= min_samples_split)

proc max_depth_rule*(max_depth: int): Rule =
    (proc(n: INode, X: seq[seq[float]], y: seq[float]): bool = n.level > max_depth)