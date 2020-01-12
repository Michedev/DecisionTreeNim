from sklearn.ensemble import RandomForestClassifier
import pandas as pd
from path import Path

def main():
    root = Path(__file__).parent.parent 
    data_folder = root / 'tests' / 'data'
    X_train = pd.read_csv(data_folder / 'X_iris.csv', header=None).values
    y_train = pd.read_csv(data_folder / 'y_iris.csv', header=None).values.ravel()
    rf = RandomForestClassifier(100, max_depth=10)
    rf.fit(X_train, y_train)


if __name__ == "__main__":
    main()