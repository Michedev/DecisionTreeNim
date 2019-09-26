import tables
import math
import sequtils

proc summary_prob(y: seq[float], f_prob: proc(p: float): float): float {.gcsafe.} =
    let counter = y.to_count_table()
    result = 0.0
    for freq in counter.values:
        let prob = freq.float / y.len().float
        result += f_prob(prob)

proc entropy_function(p: float): float {.gcsafe.} =
    - (p * ln(p))

proc entropy*(y: seq[float]): float {.gcsafe.} =
    summary_prob(y, entropy_function)

proc gini_function(p: float): float {.gcsafe.} =
    p * (1 - p)

proc gini*(y: seq[float]): float {.gcsafe.} =
    summary_prob(y, gini_function)

proc mse_from_mean*(y: seq[float]): float {.gcsafe.} =
    result = 0.0
    let mean = y.sum() / y.len().float
    for value in y:
        result += (value - mean) * (value - mean)