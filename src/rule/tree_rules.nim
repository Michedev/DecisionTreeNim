import ../node/inode
import sequtils
import ../node/splitresult

type 
    Rule* = proc(n: INode, X: seq[seq[float]], y: seq[float]): bool
    PostSplitRule* = proc(n: INode, X: seq[seq[float]], y: seq[float], split: SplitResult): bool
    TreeStopRules*  = ref object
        creation_rules: seq[Rule]
        pre_split_rules: seq[Rule]
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

proc validate_any(rules: seq[Rule], n: INode, X: seq[seq[float]], y: seq[float]): bool =
    for rule in rules:
        if rule(n, X, y):
            return true
    return false

proc validate_any(rules: seq[PostSplitRule], n: INode, X: seq[seq[float]], y: seq[float], split: SplitResult): bool =
    for rule in rules:
        if not rule(n, X, y, split):
            return false
    return true

proc validate_creation*(tsr: TreeStopRules, n: INode, X: seq[seq[float]], y: seq[float]): bool =
    validate_any(tsr.creation_rules, n, X, y)

proc validate_pre_split*(tsr: TreeStopRules, n: INode, X: seq[seq[float]], y: seq[float]): bool =
    validate_any(tsr.pre_split_rules, n, X, y)

proc validate_post_split*(tsr: TreeStopRules, n: INode, X: seq[seq[float]], y: seq[float], split: SplitResult): bool =
    validate_any(tsr.post_split_rules, n, X, y, split)