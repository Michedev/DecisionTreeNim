import ../task
type 
        Node* = ref object of RootObj
                sons*: array[2, Node]
                split_value*: float
                split_column*: int
                level*: Natural
                task*: Task
                impurity*: proc(y: seq[float]): float
        Leaf* = ref object of Node
                leaf_f*: proc(x: seq[float]): float

proc is_leaf*(n: Node): bool = n is Leaf