# Decision tree with nim

Nim package for decision trees and random forest


### Package features
- Inspired by Scikit-learn api
- Random forest can train and predict in parallel
- Actually you feed the X matrix of size [n x m] as `seq[seq[float]]` RowMajor and the y array of size [n] as `seq[float]`
- TODO: explain with a picture the custom stop rules 


```
import decision_tree

let dt = new_classification_tree(max_depth=10)
dt.fit(X_train,y_train)
let yhat = dt.predict(X_test) #or predict_proba

```

### Random forest

```
import decision_tree

let rf = new_random_forest_classifier(n_trees=100, num_threads=4)
rf.fit(X_train, y_train)
let yhat = rf.predict(X_test) #or predict_proba
```
