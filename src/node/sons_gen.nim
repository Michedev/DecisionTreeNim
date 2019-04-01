import node, split, constructors, stop, leaf

proc generate_sons(n: Node, X: seq[seq[float]], y: seq[float]): Node =
    let split: SplitResult = best_split[true](n, X, y)
    var 
        X1 = new_seq[seq[float]]()
        y1 = new_seq[float]()
        X2 = new_seq[seq[float]]()
        y2 = new_seq[float]()
        X_splitted = [X1, X2]
        y_splitted = [y1, y2]
    for i in [0,1]:
        for indx in split.index[i]:
            X_splitted[i].add(X[indx])
            y_splitted[i].add(y[indx])
    for i in [0, 1]:
        if stop.on_creating_new_node(n, X_splitted[i], y_splitted[i]):
            n.sons[i] = new_leaf(n, X_splitted[i], y_splitted[i])
        else:
            n.sons[i] = new_node(n)
    for i, son in n.sons:
        if not(son is Leaf):
            let _ = son.generate_sons(X_splitted[i], y_splitted[i])