import ../src/random_forest/random_forest
import ../tests/test_utils
# import nimprof


proc iris_bench() =
    let rf = new_random_forest_classifier(100)
    const times = 20
    let X_data = read_X_data("tests/data/X_iris.csv", times=times)
    let y_data = read_y_data("tests/data/y_iris.csv", times=times)
    rf.fit(X_data, y_data)
    echo "Successfull finished training of a Random Forest of 100 trees"
    

iris_bench()
