# matlab_utils.py

import numpy as np

def mean(arr):
    arr = np.asarray(arr, dtype=np.float16)
    total = np.float16(0.0)
    for val in arr:
        total += val
    return np.float16(total / len(arr))

def var(arr, ddof=0):
    arr = np.asarray(arr, dtype=np.float16)
    m = mean(arr)
    total = np.float16(0.0)
    for val in arr:
        diff = val - m
        total += diff * diff
    return np.float16(total / (len(arr) - ddof))

def rms(arr):
    arr = np.asarray(arr, dtype=np.float16)
    total = np.float16(0.0)
    for val in arr:
        total += val * val
    return np.float16(np.sqrt(total / len(arr)))

def diff(arr, n=1):
    arr = list(np.asarray(arr, dtype=np.float16))
    for _ in range(n):
        diff_result = []
        for i in range(1, len(arr)):
            diff_result.append(np.float16(arr[i] - arr[i - 1]))
        arr = diff_result
    return np.array(arr, dtype=np.float16)

def xcorr(x, y=None):
    x = np.asarray(x, dtype=np.float16)
    if y is None:
        y = x
    else:
        y = np.asarray(y, dtype=np.float16)
    x_len = len(x)
    y_len = len(y)
    result_len = x_len + y_len - 1
    result = np.zeros(result_len, dtype=np.float16)
    for i in range(result_len):
        sum_val = np.float16(0.0)
        for j in range(x_len):
            k = i - j
            if 0 <= k < y_len:
                sum_val += x[j] * y[k]
        result[i] = sum_val
    return result

def unwrap(p):
    p = np.asarray(p, dtype=np.float16)
    unwrapped = [p[0]]
    shift = np.float16(2 * np.pi)
    for i in range(1, len(p)):
        delta = p[i] - p[i-1]
        if delta > np.pi:
            unwrapped.append(np.float16(unwrapped[-1] + delta - shift))
        elif delta < -np.pi:
            unwrapped.append(np.float16(unwrapped[-1] + delta + shift))
        else:
            unwrapped.append(np.float16(unwrapped[-1] + delta))
    return np.array(unwrapped, dtype=np.float16)

def atan2(y, x):
    y = np.asarray(y, dtype=np.float16)
    x = np.asarray(x, dtype=np.float16)
    result = []
    for yi, xi in zip(y, x):
        result.append(np.float16(np.arctan2(yi.astype(np.float32), xi.astype(np.float32))))
    return np.array(result, dtype=np.float16)
