type 
    SplitResult* = ref object
        split_value*: float32
        impurity*: float32
        col*: int
        index*: array[2, seq[int]]
        impurity_1*: float32
        impurity_2*: float32


proc new_split_result*(split_value, impurity: float32): SplitResult =
    result = new(SplitResult)
    result.split_value = split_value
    result.impurity = impurity
        
proc new_split_result*(split_value, impurity: float32, col: int, index: array[2, seq[int]], impurity_1: float32 = 0.0, impurity_2: float32 = 0.0): SplitResult =
    result = new(SplitResult)
    result.split_value = split_value
    result.impurity = impurity
    result.col = col
    result.index = index
    result.impurity_1 = impurity_1
    result.impurity_2 = impurity_2
