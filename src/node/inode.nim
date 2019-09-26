import ../task

type INode* = ref object
    tree_task*: Task
    impurity_f*: proc(y: seq[float]): float {.gcsafe.}
    level*: Natural
    split_value*: float
    split_column*: int
