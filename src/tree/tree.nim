import node/[node, constructors, split]

type DecisionTree* = ref object
    root: Node



proc fit(t: DecisionTree, X: seq[seq[float]], y: seq[float]): DecisionTree =
    t.root = new_node()
    let split_info = t.root.best_split(X,y)
    t.root.split_column = split_info.col

    return t