import ../node/[node, constructors, split, sons_gen]
import ../task

type DecisionTree* = ref object
    root: Node

proc new_tree(task: Task): DecisionTree =
    result = new(DecisionTree)
    result.root = new_root(task)


proc new_classification_tree(): DecisionTree = new_tree(task=Classification) 


proc new_regression_tree(): DecisionTree = new_tree(task=Regression)


proc fit(t: DecisionTree, X: var seq[seq[float]], y: var seq[float]): DecisionTree =
    var border: seq[Node] = new_seq[Node](0)
    border[0] = t.root
    while border.len > 0:
        let node = border.pop()
        let sons = node.generate_sons(X, y)