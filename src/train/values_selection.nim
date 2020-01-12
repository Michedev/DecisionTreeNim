import ../view
import algorithm
import math

##Strategies to get split values

proc uniform*(data: ColumnMatrixView[float32], n: int): seq[float32] =
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

proc percentiles*(data: ColumnMatrixView[float32], n: int): seq[float32] =
    let data_sorted = data.to_seq.sorted
    if data.len < n:
        result = new_seq[float32](data.len - 1)
        for i in 0..<data_sorted.len-1:
            result[i] = (data_sorted[i] + data_sorted[i+1]) / 2.0
        return result

    result = new_seq[float32](n-1)
    for i in 0..<(n-1):
        let data_index = ((i + 1).float32 / n.float32 * data_sorted.len.float32).round.int
        if data_index >= data.len - 1:
            continue
        result[i] = (data_sorted[data_index] + data_sorted[data_index+1]) / 2.0
