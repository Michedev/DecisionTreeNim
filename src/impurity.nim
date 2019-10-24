import tables
import math
import options
import neo
import matrix_view

type
    ImpurityF* = proc(y: CountTableRef[float]): float {.gcsafe.}

func summary_prob(probs: CountTableRef[float], f_prob: proc(p: float): float {.gcsafe, inline, nosideeffect.}): float {.gcsafe.}  =
    result = 0.0
    var tot = 0
    for p in probs.values:
        tot += p
    for prob in probs.values:
        result += f_prob(prob.float / tot.float)

func entropy_function(p: float): float {.gcsafe, inline.} =
    - (p * ln(p))

proc entropy*(y: CountTableRef[float]): float {.gcsafe.} =
    summary_prob(y, entropy_function)

func gini_function(p: float): float {.gcsafe, inline.} =
    p * (1 - p)

proc gini*(y: CountTableRef[float]): float {.gcsafe.} =
    summary_prob(y, gini_function)

proc mse_from_mean*(y: CountTableRef[float]): float {.gcsafe.} =
    result = 0.0
    # let mean_value = y.mean()
    # for value in y:
    #     result += (value - mean_value) * (value - mean_value)