import ../task
import ../impurity

type INode* = ref object
    tree_task*: Task
    impurity_f*: ImpurityF
    level*: Natural
    split_value*: float
    split_column*: int
