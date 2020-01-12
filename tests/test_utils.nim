import strutils

proc read_X_data*(path: string, sep: char = ',', times: int = 1) : seq[seq[float32]] =
    result = new_seq[seq[float32]](0)
    for i in 0..<times:
        let f: File = open path
        var i = 0
        for l in f.lines():
            let splitted = l.split sep
            var row = new_seq[float32](len(splitted))
            for i, el in splitted:
                row[i] = el.parseFloat()
            result.add row
            inc i
        f.close()
    
proc read_y_data*(path: string, times: int = 1): seq[float32] =
    result = new_seq[float32](0)
    for i in 0..<times:
        let f: File = open path
        var i = 0
        for l in f.lines():
            result.add l.parseFloat()
            inc i
        f.close()


proc accuracy*[IntFloat: int|float32](ytrue, ypred: seq[IntFloat]): float32 =
    assert ytrue.len == ypred.len
    var correct = 0
    for i in 0..<ytrue.len:
        if ytrue[i] == ypred[i]:
            inc correct
    return correct.float32 / ytrue.len.float32