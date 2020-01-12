import tables
import math
import sequtils

proc summary_prob(y: sink seq[float32], f_prob: proc(p: float32): float32): float32 {.gcsafe.} =
    let counter = y.to_count_table()
    result = 0.0
    for freq in counter.values:
        let prob = freq.float32 / y.len().float32
        result += f_prob(prob)

proc entropy_function(p: float32): float32 {.gcsafe.} =
    - (p * ln(p))

proc entropy*(y: sink seq[float32]): float32 {.gcsafe.} =
    result = 0.0
    for p in y:
        result +=  - (p * ln(p))

# proc gini_function(p: float32): float32 {.gcsafe inline.} =
#     p * (1 - p)

proc gini*(y: sink seq[float32]): float32 {.gcsafe.} =
    result = 0.0
    for p in y:
        result +=  p * (1 - p)


proc mse_from_mean*(y: sink seq[float32]): float32 {.gcsafe.} =
    result = 0.0
    let mean = y.sum() / y.len().float32
    for value in y:
        result += (value - mean) * (value - mean)