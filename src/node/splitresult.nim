type 
    SplitResult* = ref object
        split_value*: float
        impurity*: float
        col*: int
        index*: array[2, seq[int]]