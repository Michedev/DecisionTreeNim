import strutils

proc read_X_data*(path: string, sep: char = ',') : seq[seq[float]] =
    let f: File = open path
    result = new_seq[seq[float]](0)
    var i = 0
    for l in f.lines():
        let splitted = l.split sep
        var row = new_seq[float](len(splitted))
        for i, el in splitted:
            row[i] = el.parse_float()
        result.add row
        inc i
    f.close()
 
proc read_y_data*(path: string): seq[float] =
    let f: File = open path
    result = new_seq[float](0)
    var i = 0
    for l in f.lines():
        result.add l.parse_float()
        inc i
    f.close()


proc accuracy*[IntFloat: int|float](ytrue, ypred: seq[IntFloat]): float =
    assert ytrue.len == ypred.len
    var correct = 0
    for i in 0..<ytrue.len:
        if ytrue[i] == ypred[i]:
            inc correct
    return correct.float / ytrue.len.float