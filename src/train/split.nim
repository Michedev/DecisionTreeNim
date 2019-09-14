import ../node/node
import algorithm
import system
import math
import ../utils

import splitresult

type ImpurityF = proc(y: seq[float]): float

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

proc next_different(data: seq[float], i: int): float {.inline.} =
    if data.len == i + 1:
        return data[i] * 0.9
    for j in (i+1)..<data.len:
        if data[j] != data[i]:
            return data[j]
    return data[i] * 0.9


#TODO: try to submit into stats package
# use percentiles as split values
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
        let with_next = (sorted_data[i] + sorted_data.next_different(i)) / 2
        result.add with_next
    result = result[1..(result.len-2)]

proc split_y_by_value[with_index: static[bool]](x_col, y: seq[float], split_value: float): tuple[y1, y2: seq[float], i1, i2: seq[int]] =
    var y1 = new_seq[float](0)
    var y2 = new_seq[float](0)
    when with_index:
        var i1 = new_seq[int](0)
        var i2 = new_seq[int](0)
    for i, v in x_col:
        if v < split_value:
            y1.add y[i]
            when with_index:
                i1.add i
        else:
            y2.add y[i]
            when with_index:
                i2.add i
    when with_index:
        return (y1, y2, i1, i2)
    else:
        return (y1, y2, @[], @[])


proc best_split_col[with_index: static[bool]](impurity_f: ImpurityF, x_col: seq[float], y: seq[float]): SplitResult =
    assert x_col.len == y.len
    let splits = percentiles(x_col)
    echo "splits: ", splits
    var min_impurity = Inf
    var best_split = 0.0
    when with_index:
        var best_i1: seq[int]
        var best_i2: seq[int]
    for split in splits:
        let (y1, y2, i1, i2) = split_y_by_value[with_index](x_col, y, split)
        let impurity_y1 = impurity_f(y1)
        let impurity_y2 = impurity_f(y2)
        let tot_impurity: float = impurity_y1 + impurity_y2
        if min_impurity > tot_impurity:
            min_impurity = tot_impurity
            best_split = split
            when with_index:
                best_i1 = i1
                best_i2 = i2
    when with_index:
        return new_split_result(best_split, min_impurity, -1, [best_i1, best_i2])
    else:
        return new_split_result(best_split, min_impurity)


proc best_split*[with_index: static[bool]](impurity_f: ImpurityF, X: seq[seq[float]], y: seq[float]): SplitResult =
    var 
        best_split: SplitResult = new_split_result(-1, Inf)
    for j in 0..<X[0].len:
        echo "column ", j
        let j_split = best_split_col[with_index](impurity_f, X.column(j), y)
        if best_split.impurity > j_split.impurity:
            echo "new best_split.impurity ",  j_split.impurity
            echo "new best_split.split_value ",  j_split.split_value
            best_split = j_split
            best_split.col = j
    return best_split
