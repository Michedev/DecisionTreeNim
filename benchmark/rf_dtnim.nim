import ../src/DecisionTree
import ../tests/test_utils
import times
# import nimprof

proc main(): void =
    let X_iris = read_X_data("tests/data/X_iris.csv")
    let y_iris = read_y_data("tests/data/y_iris.csv")
    let rf = new_random_forest_classifier(100, num_threads=1)
    var start = now()
    rf.fit(X_iris, y_iris)
    let time_fit = now() - start
    echo "seconds fit: ", time_fit.inMilliseconds.float / 1000

main()