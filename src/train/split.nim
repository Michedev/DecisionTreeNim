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
import ../matrix_view_sorted
import times
import neo/dense
import ../matrix_view
import strutils

proc next_different(data: ColMatrixViewSorted[float], i: int): tuple[value: float, i: int] {.inline.} =
    if data.len == i + 1:
        return(data[i], i)
    for j in (i+1)..<data.len:
        if data[j] != data[i]:
            return (data[j], j)
    return (data[i], i)

proc prev_different(data: ColMatrixViewSorted[float], i: int): tuple[value: float, i: int] {.inline.} =
    if i == 0:
        return(data[i], i)
    for j in 1..i:
        if abs(data[i] - data[i-j]) > 10e-5:
            return (data[i-j], i-j)
    # echo "prev diff not found"
    let (next_diff, i_next_diff) = next_different(data, i)
    return (next_diff, i_next_diff-1)
    

#TODO: try to submit into stats package
# use percentiles as split values
# proc percentiles(data: VectorView[float]): VectorView[float] =
#     let sorted_data = data.sorted(cmp)
#     if sorted_data.len() <= 10:
#         result = @[]
#         for i, v in sorted_data:
#             if i < sorted_data.len() - 1:
#                 result.add v
#                 result.add (v + sorted_data[i+1]) / 2
#         return result 
#     result = zeros()
#     for perc in 1..9:
#         let i = (perc / 10 * sorted_data.len().float).round.int
#         let with_next = (sorted_data[i] + sorted_data.next_different(i)) / 2
#         result.add with_next
#     result = result[1..(result.len-2)]

# proc uniform_values[N: static[int]](data: ColMatrixView[float]): array[N, float] =
#     var
#         min_value = data[0]
#         max_value = data[0]
#     for v in data:
#         if min_value > v:
#             min_value = v
#         if max_value < v:
#             max_value = v
#     for i in 0..<N:
#         result[i] = min_value + max_value * (i+1).float / (N+1).float

proc uniform_values(data: ColMatrixViewSorted[float], N: int): seq[int] =
    result = new_seq[int](N)
    for i in 1..<(N+1):
        result[i-1] = (data.len.float * i.float / (N+1).float).round.int
        

proc split_y_by_value(x_col: ColMatrixView[float], y: VectorView[float], split_value: float): tuple[y1, y2: VectorView[float], i1, i2: seq[int], ct1, ct2: CountTableRef[float]] =
    var 
        i1 = new_seq[int](y.len)
        i2 = new_seq[int](y.len)
        ct1 = newCountTable[float](64)
        ct2 = newCountTable[float](64)
        elen_i1 = 0
        elen_i2 = 0
    for i, v in x_col:
        if v < split_value:
            i1[elen_i1] = i
            ct1.inc y[i]
            inc elen_i1
        else:
            i2[elen_i2] = i
            ct2.inc y[i]
            inc elen_i2
    if elen_i1 > 0:
        i1.setLen elen_i1
    else:
        i1 = @[]
    if elen_i2 > 0:
        i2.setLen elen_i2
    else:
        i2 = @[]
    let
        y1 = new_vector_view(y, i1)
        y2 = new_vector_view(y, i2)
    return (y1, y2, i1, i2, ct1, ct2)

proc split_y_by_index(x_col: ColMatrixViewSorted[float], y: VectorView[float], i_divide: int): tuple[y1, y2: VectorView[float], i1, i2: seq[int], ct1, ct2: CountTableRef[float]] =
    # echo"ylen ", y.len
    # echo"xcol len: ", x_col.len
    # echo"i_divide: ", i_divide
    var
        i1 = new_seq[int](i_divide+1)
        i2 = new_seq[int](x_col.len - i_divide-1)
        ct1 = newCountTable[float](64)
        ct2 = newCountTable[float](64)
    for i in 0..i_divide:
        i1[i] = x_col.index_of(i)
        ct1.inc y.original[i1[i]]
    for i in (i_divide+1)..<x_col.len:
        i2[i - i_divide - 1] = x_col.index_of(i)
        ct2.inc y.original[i2[i - i_divide - 1]]
    let
        y1 = new_vector_view(y, i1)
        y2 = new_vector_view(y, i2)
    var tot_count = 0
    for v in ct1.values:
        tot_count += v
    for v in ct2.values:
        tot_count += v
    assert tot_count == x_col.len
    return (y1, y2, i1, i2, ct1, ct2)

proc split_y_by_indexes*(x_col: ColMatrixViewSorted[float], y: VectorView[float], i_splits: seq[int]): seq[tuple[i1, i2: seq[int], ct1, ct2: CountTableRef[float]]] =
    # echo"ylen ", y.len
    # echo"xcol len: ", x_col.len
    # echo"i_divide: ", i_divide
    result = new_seq[tuple[i1, i2: seq[int], ct1, ct2: CountTableRef[float]]](0)
    var valid_splits = new_seq[int](0)
    for i in 0..<i_splits.len:
        var
            i1 = new_seq[int](i_splits[i]+1)
            i2 = new_seq[int](x_col.len - i_splits[i]-1)
            ct1 = newCountTable[float](64)
            ct2 = newCountTable[float](64)
        if i1.len == 0 or i2.len == 0:
            continue
        result.add (i1, i2, ct1, ct2)
        valid_splits.add i_splits[i]
    for i in 0..<x_col.len:
        let i_sort = x_col.index_of(i)
        let y_label = y.original[i_sort]
        for j, i_split in valid_splits:
            if i <= i_split:
                result[j].i1[i] = i_sort
                result[j].ct1.inc y_label
            else:
                let i2_i = i - i_split - 1
                result[j].i2[i2_i] = i_sort
                result[j].ct2.inc y_label

proc best_split_col(impurity_f: ImpurityF, x_col: ColMatrixViewSorted[float], y: VectorView[float]): SplitResult {.gcsafe.} =
    assert x_col.len == y.len, "len of x is " &  x_col.len.intToStr & " while y is " & y.len.intToStr # & "\nindex of x: " & $x_col.index_sorted.row_index & "\nindex of y: " & $y.index
    # echo "x_col.row_index ", x_col.row_index
    let indx_splits = uniform_values(x_col, log2(x_col.len.float).round.int)
    if indx_splits.len == 0:
        return new_split_result(-1, Inf)
    var min_impurity = Inf
    var best_split = 0.0
    var best_i1: seq[int]
    var best_i2: seq[int]
    var best_i_divide = -1
    let splits = split_y_by_indexes(x_col, y, indx_splits)
    for i, (i1, i2, ct1, ct2) in splits:
        let i_split = indx_splits[i]
        let split_value = x_col[i_split]
        let impurity_y1 = impurity_f(ct1)
        let impurity_y2 = impurity_f(ct2)
        let tot_impurity: float = impurity_y1 + impurity_y2
        # echo "impurity split: ", tot_impurity
        
        if min_impurity > tot_impurity:
            min_impurity = tot_impurity
            best_split = split_value
            best_i1 := i1
            best_i2 := i2
            best_i_divide = i_split
        # echo"x_col.index_sorted.row_index: ", x_col.index_sorted.row_index
    return new_split_result(best_split, min_impurity, x_col.col_index, best_i1, best_i2)

proc random_features(num_features: int, max_features: float): seq[int] =
    var sampled_features = (max_features * num_features.float).ceil.int
    return generate_random_sequence(num_features-1, sampled_features)

        

proc best_split*(impurity_f: ImpurityF, X: MatrixViewSorted[float], y: VectorView[float], max_features: float = 1.0): SplitResult {.gcsafe.} =
    # echo "X.row_index ", X.row_index
    var 
        best_split: SplitResult = new_split_result(-1, Inf)
    if y.len == 0:
        return best_split
    for j in random_features(X.N, max_features):
        # echo "split on column ", j
        let j_split: SplitResult = best_split_col(impurity_f, X.column_sorted(j), y)
        if best_split.impurity > j_split.impurity:
            best_split = j_split
    # echo "best split on column ", $best_split.col, " with value ", $best_split.split_value & " and impurity " & $best_split.impurity
    # echo "best split len split 1: " & $best_split.i1.len & " best split len split 2: " & $best_split.i2.len
    # echo "i1: ", best_split.i1
    # echo "i2: ", best_split.i2
    return best_split
