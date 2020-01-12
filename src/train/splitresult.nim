type 
    SplitResult* = ref object
        split_value*: float32
        impurity*: float32
        col*: int
        index*: array[2, seq[int]]
        impurity_1*: float32
        impurity_2*: float32