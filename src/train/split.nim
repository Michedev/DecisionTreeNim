import ../node/node
import algorithm
import system
import math
import ../utils
import random
import tables
import splitresult
import options
import ../impurity
import tables
import times

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

proc uniform_values[N: static[int]](data: seq[float]): array[N, float] =
    var
        min_value = data[0]
        max_value = data[0]
    for v in data:
        if min_value > v:
            min_value = v
        if max_value < v:
            max_value = v
    for i in 0..<N:
        result[i] = min_value + max_value * (i+1).float / (N+1).float

proc split_y_by_value(x_col, y: seq[float], split_value: float): tuple[y1, y2: seq[float], i1, i2: seq[int], ct1, ct2: CountTableRef[float]] =
    var 
        y1 = new_seq[float](0)
        y2 = new_seq[float](0)
        i1 = new_seq[int](0)
        i2 = new_seq[int](0)
        ct1 = newCountTable[float](64)
        ct2 = newCountTable[float](64)

    for i, v in x_col:
        if v < split_value:
            y1.add y[i]
            i1.add i
            ct1.inc y[i]
        else:
            y2.add y[i]
            i2.add i
            ct2.inc y[i]
    return (y1, y2, i1, i2, ct1, ct2)


proc best_split_col(impurity_f: ImpurityF, x_col: seq[float], y: seq[float]): SplitResult {.gcsafe.} =
    assert x_col.len == y.len
    let splits = uniform_values[10](x_col)
    var min_impurity = Inf
    var best_split = 0.0
    var best_i1: seq[int]
    var best_i2: seq[int]
    for split in splits:
        let (y1, y2, i1, i2, ct1, ct2) = split_y_by_value(x_col, y, split)
        var
            p1 = newSeq[float](ct1.len)
            p2 = newSeq[float](ct2.len)
            i = 0
        for v in ct1.values:
            p1[i] = v / y1.len
            inc i
        i = 0
        for v in ct2.values:
            p2[i] = v / y2.len
            inc i
        let impurity_y1 = impurity_f(p1)
        let impurity_y2 = impurity_f(p2)
        var tot_impurity: float = impurity_y1 + impurity_y2
        if i1.len == 0 or i2.len == 0:
            tot_impurity = Inf
        if min_impurity > tot_impurity:
            min_impurity = tot_impurity
            best_split = split
            best_i1 = i1
            best_i2 = i2
    return new_split_result(best_split, min_impurity, -1, [best_i1, best_i2])

proc random_features(num_features: int, max_features: float): seq[int] =
    var sampled_features = (max_features * num_features.float).ceil.int
    return generate_random_sequence(num_features-1, sampled_features)

        

proc best_split*(impurity_f: ImpurityF, X: seq[seq[float]], y: seq[float], max_features: float = 1.0): SplitResult {.gcsafe.} =
    var 
        best_split: SplitResult = new_split_result(-1, Inf)
    for j in random_features(X[0].len, max_features):
        let j_split = best_split_col(impurity_f, X.column(j), y)
        if best_split.impurity > j_split.impurity:
            best_split = j_split
            best_split.col = j
    return best_split
