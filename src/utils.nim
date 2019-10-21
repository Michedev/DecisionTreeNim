import random
import times
import tables
import neo
import sets
import math
import sequtils


# proc column*(X: seq[seq[float]], j: int): seq[float] =
#     result = new_seq[float](X.len)
#     for i, row in X:
#         result[i] = row[j]

proc toCountTable*(data: Vector[float]): CountTableRef[float] =
    result = newCountTable[float](32)
    for v in data:
        result.inc v

proc generate_random_sequence*(max_value: Positive, values: Positive): seq[int] =
    var random_seq: HashSet[int]
    random_seq.init(nextPowerOfTwo(max_value))
    var r = initRand((cpuTime() * 10000000 + 1).int)
    for i in 0..<values:
        var i_sampled = r.rand(max_value)
        while i_sampled in random_seq:
            i_sampled = r.rand(max_value)
        random_seq.incl i_sampled
    return random_seq.toSeq


template `:=`*[T](x: var seq[T]; v: seq[T]) =
    shallowCopy(x, v)
