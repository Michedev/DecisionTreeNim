import ../src/tree
import unittest
import strutils
import ../src/random_forest/random_forest
import test_utils
import times

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
    test "Perfect single split with a lot of data":
        let X_long = read_X_data("tests/data/X_data")
        let y_long = read_y_data("tests/data/y_data")
        t.fit(X_long, y_long)
        var y_pred = t.predict(X_long)
        require(y_pred.len == y_long.len)
        require(y_pred == y_long)
    test "Test fit tree on iris dataset":
        let X_iris = read_X_data("tests/data/X_iris.csv")
        let y_iris = read_y_data("tests/data/y_iris.csv")
        t.fit(X_iris, y_iris)
        let yhat = t.predict(X_iris)
        require(yhat.len == y_iris.len)
        require(0.0 in yhat)
        require(1.0 in yhat)
        require(2.0 in yhat)
    test "Decision tree should overfit when predict on Iris train set":
        let X_iris = read_X_data("tests/data/X_iris.csv")
        let y_iris = read_y_data("tests/data/y_iris.csv")
        t.fit(X_iris, y_iris)
        let yhat = t.predict(X_iris)
        let accuracy_iris = accuracy(y_iris, yhat)
        require(accuracy_iris > 0.95)
        echo "accuracy on iris train set is ", accuracy_iris
    test "Random forest should overfit when predict on Iris train set":
        let X_iris = read_X_data("tests/data/X_iris.csv")
        let y_iris = read_y_data("tests/data/y_iris.csv")
        let rf = new_random_forest_classifier(100, num_threads=1)
        var start = now()
        rf.fit(X_iris, y_iris)
        let time_fit = now() - start
        start = now()
        let yhat = rf.predict(X_iris)
        let time_predict = now() - start
        let accuracy_iris = accuracy(y_iris, yhat)
        require(accuracy_iris > 0.95)
        echo "accuracy on iris train set is ", accuracy_iris
        echo "seconds fit: ", time_fit.inMilliseconds.float32 / 1000, " seconds predict: ", time_predict.inMilliseconds.float32 / 1000
    test "Random forest with parallel training should overfit when predict on Iris train set":
        let X_iris = read_X_data("tests/data/X_iris.csv")
        let y_iris = read_y_data("tests/data/y_iris.csv")
        let rf = new_random_forest_classifier(100, num_threads=4)
        var start = now()
        rf.fit(X_iris, y_iris)
        let time_fit = now() - start
        echo "seconds fit: ", time_fit.inMilliseconds.float32 / 1000
        start = now()
        let yhat = rf.predict(X_iris)
        let time_predict = now() - start
        let accuracy_iris = accuracy(y_iris, yhat)
        require(accuracy_iris > 0.95)
        echo "accuracy on iris train set is ", accuracy_iris
        echo " seconds predict: ", time_predict.inMilliseconds.float32 / 1000
    test "Random forest should overfit when predict on Iris train set x 10":
        let X_iris = read_X_data("tests/data/X_iris.csv", times=10)
        let y_iris = read_y_data("tests/data/y_iris.csv", times=10)
        let rf = new_random_forest_classifier(100, num_threads=1)
        var start = now()
        rf.fit(X_iris, y_iris)
        let time_fit = now() - start
        start = now()
        let yhat = rf.predict(X_iris)
        let time_predict = now() - start
        let accuracy_iris = accuracy(y_iris, yhat)
        require(accuracy_iris > 0.95)
        echo "accuracy on iris train set is ", accuracy_iris
        echo "seconds fit: ", time_fit.inMilliseconds.float32 / 1000, " seconds predict: ", time_predict.inMilliseconds.float32 / 1000
    test "Random forest with parallel training should overfit when predict on Iris train set x 10":
        let X_iris = read_X_data("tests/data/X_iris.csv", times=10)
        let y_iris = read_y_data("tests/data/y_iris.csv", times=10)
        let rf = new_random_forest_classifier(100, num_threads=4)
        var start = now()
        rf.fit(X_iris, y_iris)
        let time_fit = now() - start
        start = now()
        let yhat = rf.predict(X_iris)
        let time_predict = now() - start
        let accuracy_iris = accuracy(y_iris, yhat)
        require(accuracy_iris > 0.95)
        echo "accuracy on iris train set is ", accuracy_iris
        echo "seconds fit: ", time_fit.inMilliseconds.float32 / 1000, " seconds predict: ", time_predict.inMilliseconds.float32 / 1000
    