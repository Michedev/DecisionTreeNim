import ../node/node
import algorithm
import system
import math
import ../utils
import random
import splitresult
import ../view
import tables
import sugar
import ../task
import values_selection
import ../impurity
   


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

proc split_y_by_value_regression(x_col: ColumnMatrixView[float32], y: VectorView[float32], split_value: float32): tuple[y1, y2: seq[float32], m1, m2: float32, i1, i2: seq[int]] =
    var 
        mean_1: float32 = 0.0
        mean_2: float32 = 0.0
        y1: seq[float32] = new_seq[float32](0)
        y2: seq[float32] = new_seq[float32](0)
        i1 = new_seq[int](0)
        i2 = new_seq[int](0)
    for i, v in x_col:
        if v < split_value:
            mean_1 += v
            y1.add v
            i1.add i
        else:
            mean_2 += v
            y2.add v
            i2.add i
    mean_1 /= i1.len.float32
    mean_2 /= i2.len.float32
    return (y1, y2, mean_1, mean_2, i1, i2)


proc best_split_col(t: Task, impurity_f: Impurity, x_col: ColumnMatrixView[float32], y: VectorView[float32]): SplitResult {.gcsafe.} =
    ## 
    assert x_col.len == y.len
    let splits = percentiles(x_col, 10)
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
        if t == Classification:
            let (count_y1, count_y2, i1, i2) = split_y_by_value_classification(x_col, y, split)
            if i1.len == 0 or i2.len == 0:
                continue
            let freq_y1 = collect(newSeq):
                for x in count_y1.values:
                    x.float32 / y.len.float32
            let freq_y2 = collect(newSeq):
                for x in count_y2.values:
                    x.float32 / y.len.float32
            var true_impurity_f: proc(p_y: seq[float32]): float32 {.gcsafe.} = nil
            if impurity_f == Gini:
                true_impurity_f = gini
            elif impurity_f == Entropy:
                true_impurity_f = entropy
            impurity_y1 = true_impurity_f(freq_y1)
            impurity_y2 = true_impurity_f(freq_y2)
            split_i1 := i1
            split_i2 := i2
        else:
            let (y1, y2, mean_1, mean_2, i1, i2) = split_y_by_value_regression(x_col, y, split)
            if i1.len == 0 or i2.len == 0:
                continue
            if impurity_f == Mse:
                impurity_y1 = mse_from_mean(y1, mean_1)
                impurity_y2 = mse_from_mean(y2, mean_2)
                split_i1 := i1
                split_i2 := i2
            else:
                raise newException(ValueError, "impurity_f in regression must be Mse")
        let tot_impurity: float32 = impurity_y1 + impurity_y2
        if min_impurity > tot_impurity and split_i1.len > 0 and split_i2.len > 0:
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

proc best_split*(task: Task, impurity_f: Impurity, X: MatrixView[float32], y: VectorView[float32], max_features: float32 = 1.0): SplitResult {.gcsafe.} =
    var 
        best_split: SplitResult = new_split_result(-1, Inf)
    for j in random_features(X.ncols, max_features):
        let j_split = best_split_col(task, impurity_f, X.column(j), y)
        if best_split.impurity > j_split.impurity:
            best_split = j_split
            best_split.col = j
    return best_split
