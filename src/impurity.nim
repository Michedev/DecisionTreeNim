import tables
import math
import options

type
    ImpurityF* = proc(y: seq[float]): float {.gcsafe.}

func summary_prob(probs: seq[float], f_prob: proc(p: float): float {.gcsafe, inline, nosideeffect.}): float {.gcsafe.}  =
    result = 0.0
    for prob in probs:
        result += f_prob(prob)

func entropy_function(p: float): float {.gcsafe, inline.} =
    - (p * ln(p))

proc entropy*(y: seq[float]): float {.gcsafe.} =
    summary_prob(y, entropy_function)

func gini_function(p: float): float {.gcsafe, inline.} =
    p * (1 - p)

proc gini*(y: seq[float]): float {.gcsafe.} =
    summary_prob(y, gini_function)

proc mse_from_mean*(y: seq[float]): float {.gcsafe.} =
    result = 0.0
    let mean = y.sum() / y.len().float
    for value in y:
        result += (value - mean) * (value - mean)