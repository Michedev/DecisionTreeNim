import ../node/[node, constructors]
import sons_gen
import options
import ../view

type NodeWithData = tuple[n: Node, X: MatrixView[float32], y: VectorView[float32]]

## Train function of decision tree
proc fit* (root: Node, X: MatrixView[float32], y: VectorView[float32]) {.gcsafe.} =
    assert X.len == y.len
    var border = new_seq[NodeWithData](1)
    border[0] = (root, X, y)
    while border.len > 0:
        let (node, X_data, y_data) = border.pop()
        let sons_opt = node.generate_sons(X_data, y_data)
        if sons_opt.is_some():
            let sons = sons_opt.get()
            if not(sons.first of Leaf):
                border.add((sons.first, sons.X1, sons.y1))
            if not(sons.second of Leaf):
                border.add((sons.second, sons.X2, sons.y2))
        elif sons_opt.is_none() and not node.father.isNil():
            let father = node.father
            if father.num_sons == 0:
                father.sons[0] = new_leaf(father, X_data, y_data)
            else:
                for i in 0..<father.num_sons:
                    let son = father.sons[i]
                    if son == node:
                        father.num_sons -= 1
                        father.sons[i] = new_leaf(father, X_data, y_data)
        else:
            raise newException(RootIsLeaf, "Root is leaf")
