import node/[node, constructors, split, sons_gen, traverse]
import task
import typetraits
import core.typeinfo
import sequtils

type 
    DecisionTree* = ref object
        root: Node
    NodeWithData = tuple[n: Node, X: seq[seq[float]], y: seq[float]]

proc new_tree(task: Task): DecisionTree =
    result = new(DecisionTree)
    result.root = new_root(task)


proc new_classification_tree*(): DecisionTree = new_tree(task=Classification) 


proc new_regression_tree*(): DecisionTree = new_tree(task=Regression)

proc fit*(t: DecisionTree, X: seq[seq[float]], y: seq[float]) =
    var border= new_seq[NodeWithData](1)
    border[0] = (t.root, X, y)
    while border.len > 0:
        let (node, X_data, y_data) = border.pop()
        let sons = node.generate_sons(X_data, y_data)
        if not(sons.first of Leaf):
            border.add((sons.first, sons.X1, sons.y1))
        if not(sons.second of Leaf):
            border.add((sons.second, sons.X2, sons.y2))

proc print_root_split*(t: DecisionTree) =
    echo "Split in column ", t.root.split_column, " with value ", t.root.split_value
            
proc predict*(t: DecisionTree, x: seq[float]): float =
    t.root.get_value(x)

proc predict*(t: DecisionTree, X: seq[seq[float]]): seq[float] =
    X.map_it(t.predict(it))