proc column*(X: seq[seq[float]], j: int): seq[float] =
    result = new_seq[float](X.len)
    for i, row in X:
        result[i] = row[j]
