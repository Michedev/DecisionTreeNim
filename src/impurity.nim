import tables
import math
import sequtils
import utils


type Impurity* = enum
    Entropy
    Gini
    Mse
    Default

proc entropy*(y: seq[float32]): float32 {.gcsafe.} =
    result = 0.0
    for p in y:
        result +=  - (p * ln(p))


proc gini*(y: seq[float32]): float32 {.gcsafe.} =
    result = 0.0
    for p in y:
        result +=  p * (1 - p)


proc mse_from_mean*(y: seq[float32], y_mean: float32): float32 {.gcsafe.} =
    result = 0.0
    for value in y:
        result += (value - y_mean) * (value - y_mean)