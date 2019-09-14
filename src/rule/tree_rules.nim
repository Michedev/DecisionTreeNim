import ../node/inode
import sequtils
import ../train/splitresult

type 
    Rule* = proc(n: INode, X: seq[seq[float]], y: seq[float]): bool
    PostSplitRule* = proc(n: INode, X: seq[seq[float]], y: seq[float], X1: seq[seq[float]], y1: seq[float], X2: seq[seq[float]], y2: seq[float]): bool
    TreeStopRules*  = ref object
        ## Rules checked when a new son node is created. If one or more stop rules are true, then makes a leaf instead of internal node 
        creation_rules: seq[Rule]
        ## Rules checked before creating a split
        pre_split_rules: seq[Rule]
        ## Rules checked after found the best split for a internal node. 
        ## The type is different from the other two because receive in input also the split informations
        post_split_rules: seq[PostSplitRule]
    TreeGrowRules* = ref object
        stop_rules*: TreeStopRules
        max_features: float

proc new_tree_stop_rules*(): TreeStopRules =
    result = new(TreeStopRules)
    result.creation_rules = @[]
    result.pre_split_rules = @[]
    result.post_split_rules = @[]

proc new_tree_grow_rules*(max_features: float = 1.0): TreeGrowRules =
    result = new(TreeGrowRules)
    result.max_features = max_features
    result.stop_rules = new_tree_stop_rules()

proc max_features*(t: TreeGrowRules): float = t.max_features

proc add_creation_rule* (tr: TreeStopRules, rule: Rule) =
    tr.creation_rules.add rule

proc add_pre_split_rule* (tr: TreeStopRules, rule: Rule) =
    tr.pre_split_rules.add rule

proc add_post_split_rule* (tr: TreeStopRules, rule: PostSplitRule) =
    tr.post_split_rules.add rule

proc any_true(rules: seq[Rule], n: INode, X: seq[seq[float]], y: seq[float]): bool =
    for rule in rules:
        if rule(n, X, y):
            return true
    return false

proc any_true(rules: seq[PostSplitRule], n: INode, X: seq[seq[float]], y: seq[float], X1: seq[seq[float]], y1: seq[float], X2: seq[seq[float]], y2: seq[float]): bool =
    for rule in rules:
        if rule(n, X, y, X1, y1, X2, y2):
            return true
    return false

proc on_creation*(tsr: TreeStopRules, n: INode, X: seq[seq[float]], y: seq[float]): bool =
    any_true(tsr.creation_rules, n, X, y)

proc on_pre_split*(tsr: TreeStopRules, n: INode, X: seq[seq[float]], y: seq[float]): bool =
    any_true(tsr.pre_split_rules, n, X, y)

proc on_post_split*(tsr: TreeStopRules, n: INode, X: seq[seq[float]], y: seq[float], X1: seq[seq[float]], y1: seq[float], X2: seq[seq[float]], y2: seq[float]): bool =
    any_true(tsr.post_split_rules, n, X, y, X1, y1, X2, y2)