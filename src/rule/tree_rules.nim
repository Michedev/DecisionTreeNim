import ../node/inode
import ../view
import ../train/splitresult


type 
    Rule* = proc(n: INode, X: MatrixView[float32], y: VectorView[float32]): bool {.gcsafe.}
    PostSplitRule* = proc(n: INode, X: MatrixView[float32], y: VectorView[float32], X1: MatrixView[float32], y1: VectorView[float32], X2: MatrixView[float32], y2: VectorView[float32], split: SplitResult): bool {.gcsafe.}
    TreeStopRules*  = ref object
        ## Rules checked when a new son node is created. If one or more stop rules are true, then makes a leaf instead of internal node 
        creation_rules: seq[Rule]
        ## Rules checked before creating a split
        pre_split_rules: seq[Rule]
        ## Rules checked after found the best split for a internal node. 
        ## The type is different from the other two because receive in input also the split informations
        post_split_rules: seq[PostSplitRule]


proc new_tree_stop_rules*(): TreeStopRules =
    result = new(TreeStopRules)
    result.creation_rules = @[]
    result.pre_split_rules = @[]
    result.post_split_rules = @[]


proc add_creation_rule* (tr: TreeStopRules, rule: Rule) =
    tr.creation_rules.add rule

proc add_pre_split_rule* (tr: TreeStopRules, rule: Rule) =
    tr.pre_split_rules.add rule

proc add_post_split_rule* (tr: TreeStopRules, rule: PostSplitRule) =
    tr.post_split_rules.add rule

proc add_creation_rules* (tr: TreeStopRules, rules: sink seq[Rule]) =
    for rule in rules:
        tr.add_creation_rule rule

proc add_pre_split_rules* (tr: TreeStopRules, rules: sink seq[Rule]) =
    for rule in rules:
        tr.add_pre_split_rule rule

proc add_post_split_rules* (tr: TreeStopRules, rules: seq[PostSplitRule]) =
    for rule in rules:
        tr.add_post_split_rule rule

proc any_true(rules: sink seq[Rule], n: INode, X: MatrixView[float32], y: VectorView[float32]): bool {.gcsafe, inline.} =
    for rule in rules:
        if rule(n, X, y):
            # echo "stop for rule ", rule
            return true
    return false

proc any_true(rules: seq[PostSplitRule], n: INode, X: MatrixView[float32], y: VectorView[float32], X1: MatrixView[float32], y1: VectorView[float32], X2: MatrixView[float32], y2: VectorView[float32], split: SplitResult): bool {.gcsafe, inline.} =
    for rule in rules:
        if rule(n, X, y, X1, y1, X2, y2, split):
            return true
    return false

proc on_creation*(tsr: TreeStopRules, n: INode, X: MatrixView[float32], y: VectorView[float32]): bool {.gcsafe.} =
    any_true(tsr.creation_rules, n, X, y)

proc on_pre_split*(tsr: TreeStopRules, n: INode, X: MatrixView[float32], y: VectorView[float32]): bool {.gcsafe.} =
    any_true(tsr.pre_split_rules, n, X, y)

proc on_post_split*(tsr: TreeStopRules, n: INode, X: MatrixView[float32], y: VectorView[float32], X1: MatrixView[float32], y1: VectorView[float32], X2: MatrixView[float32], y2: VectorView[float32], split: SplitResult): bool {.gcsafe.} =
    any_true(tsr.post_split_rules, n, X, y, X1, y1, X2, y2, split)