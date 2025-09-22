import numpy as np
import random
from pathlib import Path
from typing import List
from utils import read_binary, binary_to_fp16, store_binary, generate_fp16


def cmul(a,b,sub):
    br, bi = (-b[0], -b[1]) if sub else (b[0], b[1])
    res = [a[0]*br - a[1]*bi, a[0]*bi + a[1]*br]
    return res

def cadd(a,b,sub):
    br, bi = (-b[0], -b[1]) if sub else (b[0], b[1])
    res = [a[0] + br, a[1] + bi]
    return res

def read_rtl_file(file_path: Path) -> List[List[np.float16]]:
    """
    Read a single RTL output file and return all complex numbers
    as [real, imag] pairs.
    """
    complex_values: List[List[np.float16]] = []

    with file_path.open("r", encoding="utf-8") as f:
        for line_idx, raw_line in enumerate(f, start=1):
            words = raw_line.strip().split()
            for word_idx, word in enumerate(words, start=1):
                if len(word) != 32:
                    raise ValueError(
                        f"Line {line_idx}, word {word_idx}: "
                        f"expected 32 bits, got '{word}' (len={len(word)})"
                    )
                real_bits, imag_bits = word[:16], word[16:]
                if real_bits == 'x'*16:
                    real_bits = '1'*16
                if imag_bits == 'x'*16:
                    imag_bits = '1'*16
                real_val = np.uint16(int(real_bits,2)).view(np.float16)
                imag_val = np.uint16(int(imag_bits,2)).view(np.float16)
                complex_values.append([real_val, imag_val])

    return complex_values

def auto_corr(X,k):
    R = [np.float16(0.0), np.float16(0.0)]
    X_conj = [np.float16(0.0), np.float16(0.0)]
    tmp = [np.float16(0.0), np.float16(0.0)]

    X_conj = [[r,-i] for r,i in X]

    for n in range(len(X) - k):
        tmp = cmul(X[n],X_conj[n+k],False)
        R = cadd(R,tmp,False)
    # R = [R[0] / (len(X)-k), R[1] / (len(X)-k)] # Two definitions, one divide the number of points, one not
    return R

def auto_cova(X, k):
    C = [np.float16(0.0), np.float16(0.0)]
    X_conj = [np.float16(0.0), np.float16(0.0)]
    tmp = [np.float16(0.0), np.float16(0.0)]
    X_sum = [np.float16(0.0), np.float16(0.0)]

    X_conj = [[r,-i] for r,i in X]
    for x in X:
        X_sum = cadd(x,X_sum,False)
    mean = [np.float16(X_sum[0] / len(X)), np.float16(X_sum[1] / len(X))]
    mean_conj = [mean[0], -mean[1]]
    print(mean,mean_conj)
    for n in range(len(X) - k):
        tmp = cmul(cadd(X[n],mean,True),cadd(X_conj[n+k],mean_conj,True),False)
        C = cadd(C,tmp,False)
    print(C)
    covar = [np.float16(C[0] / (len(X)-k)), np.float16(C[1] / (len(X)-k))] # Two definitions, one divide the number of points, one not
    return covar

if __name__ == "__main__":
    N = 64        # sequence length
    k_max = 8     # max lag to check
    k = 4
    input_signal = generate_fp16(N,True,20)
    kernel = "auto_cova"
    # input_signal = [[np.float16(i+1) for __ in range(2)] for i in range(N)]
    store_binary(input_signal,Path(f"../PE/DATA/{kernel}_input.txt"))
    print(input_signal)
    r = auto_corr(input_signal,k)
    covar = auto_cova(input_signal,k)
    rtl_results = read_rtl_file(Path(f"../PE/DATA/{kernel}_out.txt"))
    print(covar)
    if kernel == "auto_cova":
        rtl_capture = rtl_results[208*4-1 + 1]
        print(rtl_capture)
        if covar == rtl_capture:
            print(f"\033[32m{kernel} is Correct\033[0m")
        else:
            print(f"\033[31m{kernel} is Wrong\033[0m")
            print(f"{kernel} kernel result is {covar}, RTL output is {rtl_capture}")





