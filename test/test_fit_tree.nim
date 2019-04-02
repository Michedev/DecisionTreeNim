import ../src/tree
import unittest

suite "Test fit classification tree":
    setup:
        let t = new_classification_tree()
        let X1 = @[@[1.0, 4.2],
                   @[5.0, 120.4],
                   @[1.0, 3212.3],
                   @[110.0, 329.12]]
        let y1 = @[0.0, 0.0, 0.0, 1.0]
    test "Perfect single split":
        t.fit(X1, y1)
        var y_pred = t.predict(X1)
        t.print_root_split()
        require(y_pred == y1)