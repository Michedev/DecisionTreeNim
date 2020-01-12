import ../task
import ../impurity

type INode* = ref object of RootObj
    tree_task*: Task
    impurity_f*: Impurity
    level*: Natural
    split_value*: float32
    split_column*: int
    impurity_value*: float32
