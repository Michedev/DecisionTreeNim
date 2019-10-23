import random
import times
import tables
import neo
import sets
import math
import sequtils
import sequtils2
import algorithm

# proc column*(X: seq[seq[float]], j: int): seq[float] =
#     result = new_seq[float](X.len)
#     for i, row in X:
#         result[i] = row[j]

proc toCountTable*(data: Vector[float]): CountTableRef[float] =
    result = newCountTable[float](32)
    for v in data:
        result.inc v

proc generate_random_sequence*(max_value: Positive, values: Positive): seq[int] =
    # echo "max value: ", max_value, " values: ", values
    if max_value == (values - 1):
        result = (0..max_value).toSeq
        return
    var random_seq: HashSet[int]
    random_seq.init(nextPowerOfTwo(max_value))
    var r = initRand((cpuTime() * 10000000 + 1).int)
    for i in 0..<values:
        var i_sampled = r.rand(max_value)
        while i_sampled in random_seq:
            i_sampled = r.rand(max_value)
        random_seq.incl i_sampled
    return random_seq.toSeq

func argsort*[T](v: seq[T]): seq[int] {.inline.} =
    v.zipWithIndex.sortedByIt(it.el).map_it(it.i)

func argsort*[T](v: Vector[T]): seq[int] {.inline.} =
    var i = 0
    var v_with_indx = new_seq[tuple[el: T, i: int]](v.len)
    for value in v:
        v_with_indx[i] = (value, i)
        inc i
    return v_with_indx.sortedByIt(it.el).map_it(it.i)
    
    
    


template `:=`*[T](x: var seq[T]; v: seq[T]) =
    shallowCopy(x, v)
