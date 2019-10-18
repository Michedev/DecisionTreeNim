import random
import times

proc column*(X: seq[seq[float]], j: int): seq[float] =
    result = new_seq[float](X.len)
    for i, row in X:
        result[i] = row[j]


proc generate_random_sequence*(max_value: Positive, values: Positive): seq[int] =
    result = newSeq[int](values)
    for i in 0..<values:
        result[i] = -1
    var r = initRand((cpuTime() * 10000000 + 1).int)
    for i in 0..<values:
        var i_sampled = r.rand(max_value)
        while i_sampled in result:
            i_sampled = r.rand(max_value)
        result[i] = i_sampled
