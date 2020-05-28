# Decision tree with nim

[![nimble](https://raw.githubusercontent.com/yglukhov/nimble-tag/master/nimble_js.png)](https://github.com/Michedev/DecisionTreeNim)

Nim package for decision trees and random forest

## How to install

`nimble install decisiontree`

### Package features
- Inspired by Scikit-learn api
- Random forest can train and predict in parallel
- Actually you feed the X matrix of size [n x m] as `seq[seq[float]]` RowMajor and the y array of size [n] as `seq[float]`

#### Decision Tree

```
import DecisionTree

let dt = DecisionTree.new_classification_tree(max_depth=10)
dt.fit(X_train,y_train)
let yhat = dt.predict(X_test)

```

#### Random forest

```
import DecisionTree

let rf = DecisionTree.new_random_forest_classifier(n_trees=100, num_threads=4) #parallel training too!
rf.fit(X_train, y_train)
let yhat = rf.predict(X_test)
```


## Benchmark with python

Note: this benchmark is not done to see if nim is quicker than python, of course a good implementation in nim requires less time since it is a statically compiled language and use C compiler optimizations. The purpuose of this benchamrk is to understand HOW MUCH is quicker so the user can decide the language and the library to use because python is slower but has more libraries for data science


##### Iris Dataset

- Dataset: [iris dataset](https://www.kaggle.com/arshid/iris-flower-dataset)
- Nim Code:


        import ../src/random_forest/random_forest
        import ../tests/test_utils

        proc iris_bench() =
            let rf = new_random_forest_classifier(100, max_depth=10)
            let X_data = read_X_data("tests/data/X_iris.csv")
            let y_data = read_y_data("tests/data/y_iris.csv")
            rf.fit(X_data, y_data)
            echo "Successfull finished training of a Random Forest of 100 trees"
            let yhat = rf.predict(X_data)
            echo "accuracy train ", accuracy(y_data, yhat)
            
        if isMainModule:
            iris_bench()

    multitime -n 30 results

                    Mean        Std.Dev.    Min         Median      Max
        real        0.205       0.046       0.124       0.190       0.302       
        user        0.191       0.042       0.110       0.180       0.297       
        sys         0.005       0.004       0.000       0.003       0.016       


- Python code:

        from sklearn.ensemble import RandomForestClassifier
        from sklearn.metrics import accuracy_score
        import pandas as pd
        from path import Path

        def main():
            root = Path(__file__).parent.parent 
            data_folder = root / 'tests' / 'data'
            X_train = pd.read_csv(data_folder / 'X_iris.csv', header=None).values
            y_train = pd.read_csv(data_folder / 'y_iris.csv', header=None).values.ravel()
            rf = RandomForestClassifier(100, max_depth=10)
            rf.fit(X_train, y_train)
            yhat = rf.predict(X_train)
            print('accuracy train', accuracy_score(y_train, yhat))


        if __name__ == "__main__":
            main()

    multitime -n 30 results:

                    Mean        Std.Dev.    Min         Median      Max
        real        2.426       0.251       2.131       2.346       3.390       
        user        2.275       0.158       2.026       2.224       2.711       
        sys         0.541       0.058       0.431       0.553       0.668       
