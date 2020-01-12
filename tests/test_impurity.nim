import ../src/impurity
import unittest
import math


proc equals(a,b,delta: float32 = 10e-4): bool =
    return abs(a - b) < delta

suite "Test impurity functions":
    setup:
        let no_uncertainity = @[1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]
        let max_uncertainity = @[0.0, 0.0, 0.0, 1.0, 1.0, 1.0]
        let random_seq: seq[float32] = @[1.0, 9.0, 1.0, 9.0, 8.0, 0.0, 7.0, 8.0, 1.0, 9.0, 4.0, 6.0, 7.0, 3.0, 0.0, 9.0, 6.0, 9.0, 5.0, 3.0]
    test "Test gini_index":
        let gini_no_unc = gini(no_uncertainity)
        require gini_no_unc.equals(0.0)
        let gini_max_unc = gini(max_uncertainity)
        require gini_max_unc.equals(0.5)
        let gini_random = gini(random_seq)
        require gini_random.equals(0.86)
    test "Test entropy":
        let entropy_no_unc = entropy(no_uncertainity)
        require entropy_no_unc.equals(0.0)
        let entropy_max_unc = entropy(max_uncertainity)
        require entropy_max_unc.equals(0.693)
        let entropy_random = entropy(random_seq)
        require entropy_random.equals(2.08, delta=10e-2)