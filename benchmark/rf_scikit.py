from sklearn.ensemble import RandomForestClassifier
import pandas as pd
import numpy as np
import time
from path import Path
from sklearn.metrics import accuracy_score

def main():
    rf = RandomForestClassifier(n_estimators=100)
    data_f = Path(__file__).parent.parent / 'tests' / 'data'
    X, y = pd.read_csv(data_f / 'X_iris.csv', header=None), pd.read_csv(data_f / 'y_iris.csv', header=None)
    times = np.zeros((100,), dtype=np.float32)
    X = X.values
    y = y.values.ravel()
    for i in range(100):
        start = time.time()
        rf.fit(X,y)
        end = time.time()
        times[i] = end - start
    print(f'Mean time (s) : {np.mean(times)} std time(s): {np.std(times)}')
    X, y = pd.read_csv(data_f / 'X_train_adult.csv', header=None), pd.read_csv(data_f / 'y_train_adult.csv', header=None)
    X_test, y_test = pd.read_csv(data_f / 'X_test_adult.csv', header=None), pd.read_csv(data_f / 'y_test_adult.csv', header=None)
    rf.fit(X,y)
    yhat = rf.predict(X_test)
    print(f"Accuracy test adult: {accuracy_score(y_test, yhat)}")

if __name__ == '__main__':
    main()
