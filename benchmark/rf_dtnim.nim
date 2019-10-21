import ../src/DecisionTree
import ../tests/test_utils
import times
# import nimprof
import math
import neo

proc main(): void =
    let X_iris = read_X_data("tests/data/X_iris.csv")
    let y_iris = read_y_data("tests/data/y_iris.csv")
    # var rf = new_random_forest_classifier(10, num_threads=1)
    # var start = now()
    # rf.fit(X_iris, y_iris)
    # let time_fit = now() - start
    # echo "seconds fit: ", time_fit.inMilliseconds.float / 1000
    let rf = new_classification_tree(max_depth=10, min_samples_split=10)
    let X_train_adult = read_X_data_neo("tests/data/X_train_adult.csv")
    let y_train_adult = read_y_data_neo("tests/data/y_train_adult.csv")
    let X_test_adult = read_X_data_neo("tests/data/X_test_adult.csv")
    let y_test_adult = read_y_data_neo("tests/data/y_test_adult.csv")
    var start = now()
    rf.fit(X_train_adult, y_train_adult)
    let time_fit = now() - start
    start = now()
    let yhat_test = rf.predict(X_test_adult)
    var time_predict = now() - start
    echo "Accuracy test: ", accuracy(y_test_adult, yhat_test)
    echo "Perc 1 prediction: ", yhat_test.sum().float / yhat_test.len.float
    echo "Time (s) fit: ", time_fit.inMilliseconds.float / 1000 , " Time (s) predict: ", time_predict.inMilliseconds.float / 1000

main()
