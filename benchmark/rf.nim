import ../src/random_forest/random_forest
import ../tests/test_utils


proc iris_bench() =
    let rf = new_random_forest_classifier(100, max_depth=10)
    const times = 1
    let X_data = read_X_data("tests/data/X_iris.csv", times=times)
    let y_data = read_y_data("tests/data/y_iris.csv", times=times)
    rf.fit(X_data, y_data)
    echo "Successfull finished training of a Random Forest of 100 trees"
    let yhat = rf.predict(X_data)
    echo "accuracy train ", accuracy(y_data, yhat)
    
if isMainModule:
    iris_bench()
