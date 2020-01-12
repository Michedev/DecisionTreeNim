type Hyperparams* = tuple[max_depth: int, min_samples_split: int, max_features: float32, min_impurity_decrease: float32, bagging: float32]

template hyperparams_binding*(T: typed) =
    proc bagging*(t: T): auto {.inline.} = t.hyperparams.bagging
    proc max_depth*(t: T): auto {.inline.} = t.hyperparams.max_depth
    proc min_samples_split*(t: T): auto {.inline.} = t.hyperparams.min_samples_split
    proc min_impurity_decrease*(t: T): auto {.inline.} = t.hyperparams.min_impurity_decrease
    proc max_features*(t: T): auto {.inline.} = t.hyperparams.max_features
