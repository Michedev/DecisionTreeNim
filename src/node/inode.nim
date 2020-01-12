import ../task

type INode* = ref object
    tree_task*: Task
    impurity_f*: proc(y: sink seq[float32]): float32 {.gcsafe.}
    level*: Natural
    split_value*: float32
    split_column*: int
