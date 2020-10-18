import ../task
import ../rule/tree_rules
import inode

type 
        Node* = ref object of INode
                sons*: array[2, Node]
                num_sons* : int
                father*: Node
                max_features*: float32
                stop_rules*: TreeStopRules
        Leaf* = ref object of Node
                leaf_f*: proc(x: seq[float32]): float32 {.gcsafe.}
                leaf_proba*: proc(x: seq[float32]): seq[float32] {.gcsafe.}
        RootIsLeaf* = object of Exception

proc is_leaf*(n: Node): bool = n is Leaf

import inode

