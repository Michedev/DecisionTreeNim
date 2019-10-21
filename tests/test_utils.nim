import strutils
import neo

proc read_X_data*(path: string, sep: char = ',', times: int = 1) : seq[seq[float]] =
    result = new_seq[seq[float]](0)
    for i in 0..<times:
        let f: File = open path
        var i = 0
        for l in f.lines():
            let splitted = l.split sep
            var row = new_seq[float](len(splitted))
            for i, el in splitted:
                row[i] = el.parse_float()
            result.add row
            inc i
        f.close()


proc read_X_data_neo*(path: string, sep: char = ',', times: int = 1) : Matrix[float] =
    let data = read_X_data(path, sep, times)
    result = data.matrix(colMajor)
        
    
proc read_y_data*(path: string, times: int = 1): seq[float] =
    result = new_seq[float](0)
    for i in 0..<times:
        let f: File = open path
        var i = 0
        for l in f.lines():
            result.add l.parse_float()
            inc i
        f.close()

proc read_y_data_neo*(path: string, times: int = 1) : Vector[float] =
    let data = read_y_data(path, times)
    result = data.vector()
        


proc accuracy*[IntFloat: int|float](ytrue, ypred: seq[IntFloat]): float =
    assert ytrue.len == ypred.len
    var correct = 0
    for i in 0..<ytrue.len:
        if ytrue[i] == ypred[i]:
            inc correct
    return correct.float / ytrue.len.float


proc accuracy*[IntFloat: int|float](ytrue: seq[IntFloat], ypred: Vector[IntFloat]): float =
    assert ytrue.len == ypred.len
    var correct = 0
    for i in 0..<ytrue.len:
        if ytrue[i] == ypred[i]:
            inc correct
    return correct.float / ytrue.len.float

proc accuracy*[IntFloat: int|float](ytrue: Vector[IntFloat], ypred: Vector[IntFloat]): float =
    assert ytrue.len == ypred.len
    var correct = 0
    for i in 0..<ytrue.len:
        if ytrue[i] == ypred[i]:
            inc correct
    return correct.float / ytrue.len.float