import ../src/tree
import unittest
import strutils

proc read_X_data() : seq[seq[float]] =
    let f: File = open "test/X_data"
    result = new_seq[seq[float]](200)
    var i = 0
    for l in f.lines():
        var row = new_seq[float](2)
        let splitted = l.split(',')
        row[0] = splitted[0].parse_float()
        row[1] = splitted[1].parse_float()
        result[i] = row
        inc i
    f.close()

proc read_y_data(): seq[float] =
    let f: File = open "test/y_data"
    result = new_seq[float](200)
    var i = 0
    for l in f.lines():
        result[i] = l.parse_float()
        inc i
    f.close()

suite "Test fit classification tree":
    setup:
        let t = new_classification_tree()
        let X1 = @[@[1.0, 4.2],
                   @[5.0, 120.4],
                   @[1.0, 3212.3],
                   @[110.0, 329.12]]
        let y1 = @[0.0, 0.0, 0.0, 1.0]
        let X_long = read_X_data()
        let y_long = read_y_data()
    test "Perfect single split":
        t.fit(X1, y1)
        var y_pred = t.predict(X1)
        t.print_root_split()
        require(y_pred == y1)
    test "Perfect single split with a lot of data":
        t.fit(X_long, y_long)
        echo "X_long.len ", X_long.len

        var y_pred = t.predict(X_long)
        require(y_pred.len == y_long.len)
        require(y_pred == y_long)
