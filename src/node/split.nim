import node
import algorithm
import system
import math
import ../utils

type 
    SplitResult* = ref object
        split_value*: float
        impurity*: float
        col*: int
        index*: array[2, seq[int]]

proc new_split_result(split_value, impurity: float): SplitResult =
    result = new(SplitResult)
    result.split_value = split_value
    result.impurity = impurity
        
proc new_split_result(split_value, impurity: float, col: int, index: array[2, seq[int]]): SplitResult =
    result = new(SplitResult)
    result.split_value = split_value
    result.impurity = impurity
    result.col = col
    result.index = index

# try to submit into stats package
proc percentiles(data: seq[float]): seq[float] =
    let sorted_data = data.sorted(cmp)
    if sorted_data.len() <= 10:
        result = @[]
        for i, v in sorted_data:
            if i < sorted_data.len() - 1:
                result.add v
                result.add (v + sorted_data[i+1]) / 2
        return result 
    result = new_seq[float]()
    for perc in 1..9:
        let i = (perc / 10 * sorted_data.len().float).round.int
        let with_prev = (sorted_data[i] + sorted_data[i-1]) / 2
        let with_next = (sorted_data[i] + sorted_data[i+1]) / 2
        result.add with_prev
        result.add with_next

proc best_split_col[with_index: static[bool]](n: Node, x_col: seq[float], y: seq[float]): SplitResult =
    let splits = percentiles(x_col)
    echo "splits: ", splits
    var min_impurity = Inf
    var best_split = 0.0
    when with_index:
        var best_i1: seq[int]
        var best_i2: seq[int]
    for split in splits:
        var y1 = new_seq[float](0)
        var y2 = new_seq[float](0)
        when with_index:
            var i1 = new_seq[int](0)
            var i2 = new_seq[int](0)
        for i, v in x_col:
            if v < split:
                y1.add y[i]
                when with_index:
                    i1.add i
            else:
                y2.add y[i]
                when with_index:
                    i2.add i
        let impurity_y1 = n.impurity(y1)
        let impurity_y2 = n.impurity(y2)
        let tot_impurity: float = impurity_y1 + impurity_y2
        if min_impurity > tot_impurity:
            min_impurity = tot_impurity
            best_split = split
            best_i1 = i1
            best_i2 = i2
    when with_index:
        return new_split_result(best_split, min_impurity, -1, [best_i1, best_i2])
    else:
        return new_split_result(best_split, min_impurity)


proc best_split*[with_index: static[bool]](n: Node, X: seq[seq[float]], y: seq[float]): SplitResult =
    var 
        best_split: SplitResult = new_split_result(-1, Inf)
        best_col = -1
    for j in 0..<X[0].len:
        echo "column ", j
        let j_split = best_split_col[with_index](n, X.column(j), y)
        if best_split.impurity > j_split.impurity:
            echo "new best_split.impurity ",  j_split.impurity
            echo "new best_split.split_value ",  j_split.split_value
            best_split = j_split
            best_split.col = j
    return best_split
