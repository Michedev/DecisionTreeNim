import sequtils
import math
import random

proc sample_wo_reins*(start, finish: int, perc: float): seq[int] =
    assert 0.0 <= perc and perc <= 1.0
    if perc == 1.0:
        return (start..finish).to_seq
    else:
        var series = (start..finish).to_seq
        let len_sub = (series.len.float * perc).round.int
        result = new_seq[int](len_sub)
        for i in 0..<len_sub:
            let i_sample = rand(series.len)
            let element = series[i_sample]
            series.del i_sample
            result[i] = element

template `:=`*[T](a,b: seq[T]): untyped =
    shallowCopy(a,b)
               