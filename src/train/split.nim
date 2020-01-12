import ../node/node
import algorithm
import system
import math
import ../utils
import random
import splitresult
import ../view
import tables
import future
import ../task

type ImpurityF = tuple[task: Task, f: proc(p_y: seq[float32]): float32]
    

proc new_split_result(split_value, impurity: float32): SplitResult =
    result = new(SplitResult)
    result.split_value = split_value
    result.impurity = impurity
        
proc new_split_result(split_value, impurity: float32, col: int, index: array[2, seq[int]], impurity_1: float32 = 0.0, impurity_2: float32 = 0.0): SplitResult =
    result = new(SplitResult)
    result.split_value = split_value
    result.impurity = impurity
    result.col = col
    result.index = index
    result.impurity_1 = impurity_1
    result.impurity_2 = impurity_2


proc next_different(data: sink seq[float32], i: int): float32 {.inline.} =
    if data.len == i + 1:
        return data[i] * 0.9
    for j in (i+1)..<data.len:
        if data[j] != data[i]:
            return data[j]
    return data[i] * 0.9


proc uniform(data: ColumnMatrixView[float32], n: int): seq[float32] =
    ## Search min and max on data and then generate n values uniformly between min and max
    result = newSeq[float32](n-1)
    var
        min_value = Inf
        max_value = - Inf
    for v in data:
        if v < min_value:
            min_value = v
        if v > max_value:
            max_value = v
    for i in 1..(n-1):
        result[i-1] = min_value + (max_value - min_value).float32 * i.float32 / n.float32

proc split_y_by_value_classification(x_col: ColumnMatrixView[float32], y: VectorView[float32], split_value: float32): tuple[y1, y2: CountTableRef[float32], i1, i2: seq[int]] =
    var 
        y1 = newCountTable[float32]((y.len / 2).int.nextPowerOfTwo)
        y2 = newCountTable[float32]((y.len / 2).int.nextPowerOfTwo)
        i1 = new_seq[int](0)
        i2 = new_seq[int](0)
    for i, v in x_col:
        if v < split_value:
            y1.inc y.get_raw(i)
            i1.add i
        else:
            y2.inc y.get_raw(i)
            i2.add i
    return (y1, y2, i1, i2)

proc split_y_by_value_regression(x_col: ColumnMatrixView[float32], y: VectorView[float32], split_value: float32): tuple[m1, m2: float32, i1, i2: seq[int]] =
    var 
        y1 = 0.0
        y2 = 0.0
        i1 = new_seq[int](0)
        i2 = new_seq[int](0)
    for i, v in x_col:
        if v < split_value:
            y1 += y.get_raw(i)
            i1.add i
        else:
            y2 += y.get_raw(i)
            i2.add i
    y1 /= i1.len.float32
    y2 /= i2.len.float32
    return (y1, y2, i1, i2)
    


proc best_split_col(impurity_f: ImpurityF, x_col: ColumnMatrixView[float32], y: VectorView[float32]): SplitResult {.gcsafe.} =
    ## 
    assert x_col.len == y.len
    let splits = uniform(x_col, 10)
    var min_impurity = Inf
    var best_split = 0.0
    var best_i1: seq[int]
    var best_i2: seq[int]
    var min_impurity_1: float32 = 0.0
    var min_impurity_2: float32 = 0.0
    for split in splits:
        var
            impurity_y1 = Inf
            impurity_y2 = Inf
            split_i1: seq[int] = @[]
            split_i2: seq[int] = @[]
        case impurity_f.task:
            of Classification:
                let (y1, y2, i1, i2) = split_y_by_value_classification(x_col, y, split)
                let freq_y1 = lc[x.float32 / y.len.float32 | (x <- y1.values), float32]
                let freq_y2 = lc[x.float32 / y.len.float32 | (x <- y2.values), float32]
                impurity_y1 = impurity_f.f(freq_y1)
                impurity_y2 = impurity_f.f(freq_y2)
                split_i1 := i1
                split_i2 := i2
            of Regression:
                let (mean_1, mean_2, i1, i2) = split_y_by_value_regression(x_col, y, split)
                impurity_y1 = impurity_f.f(@[mean_1])
                impurity_y2 = impurity_f.f(@[mean_2])
                split_i1 := i1
                split_i2 := i2
        let tot_impurity: float32 = impurity_y1 + impurity_y2
        if min_impurity > tot_impurity:
            min_impurity = tot_impurity
            best_split = split
            best_i1 := split_i1
            best_i2 := split_i2
            min_impurity_1 = impurity_y1
            min_impurity_2 = impurity_y2
    return new_split_result(best_split, min_impurity, -1, [best_i1, best_i2], min_impurity_1, min_impurity_2)

proc random_features(num_features: int, max_features: float32): seq[int] =
    result = newSeq[int](0)
    for i in 0..<num_features:
        if rand(1.0) < max_features:
            result.add i

proc best_split*(impurity_f: ImpurityF, X: MatrixView[float32], y: VectorView[float32], max_features: float32 = 1.0): SplitResult {.gcsafe.} =
    var 
        best_split: SplitResult = new_split_result(-1, Inf)
    for j in random_features(X.ncols, max_features):
        let j_split = best_split_col(impurity_f, X.column(j), y)
        if best_split.impurity > j_split.impurity:
            best_split = j_split
            best_split.col = j
    return best_split
