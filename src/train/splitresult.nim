import ../utils

type 
    SplitResult* {.shallow.} = ref object
        split_value*: float
        impurity*: float
        col*: int
        i1* : seq[int]
        i2* : seq[int]


proc new_split_result*(split_value, impurity: float): SplitResult =
    result = new(SplitResult)
    result.split_value = split_value
    result.impurity = impurity
        
proc new_split_result*(split_value, impurity: float, col: int, i1, i2: seq[int]): SplitResult =
    result = new(SplitResult)
    result.split_value = split_value
    result.impurity = impurity
    result.col = col
    result.i1 := i1
    result.i2 := i2