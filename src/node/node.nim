import ../task
import ../rule/tree_rules

type 
        Node* = ref object of RootObj
                sons*: array[2, Node]
                num_sons* : int
                father*: Node
                split_value*: float
                split_column*: int
                level*: Natural
                max_features*: float
                tree_task*: Task
                impurity*: proc(y: sink seq[float]): float {.gcsafe.}
                stop_rules*: TreeStopRules
                impurity_value*: float
        Leaf* = ref object of Node
                leaf_f*: proc(x: seq[float]): float {.gcsafe.}
                leaf_proba*: proc(x: seq[float]): seq[float] {.gcsafe.}
        RootIsLeaf* = object of Exception

proc is_leaf*(n: Node): bool = n is Leaf

import inode

converter toINode*(n: Node): INode =
        result = new(INode)
        result.tree_task = n.tree_task
        result.impurity_f = n.impurity
        result.split_column = n.split_column
        result.split_value = n.split_value
    