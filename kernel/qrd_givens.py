import numpy as np
from pathlib import Path
from scipy.stats import kurtosis as scipy_kurtosis
from CMAC import cadd, cmul, cdiv, binary_to_fp16, fp16_to_binary
from utils import read_binary, store_binary, generate_fp16
from typing import List
from rtl_read import read_rtl_file

def generate_matrix(rows, cols, complex=False, seed=123):
    """
    Generate an (rows x cols) matrix using generate_fp16().
    """
    vec = generate_fp16(size=rows * cols, complex=complex, seed=seed)
    mat = []
    idx = 0
    for _ in range(rows):
        row = []
        for _ in range(cols):
            row.append(vec[idx])
            idx += 1
        mat.append(row)
    return mat

def flatten_matrix_row_major(mat, complex=False):
    """
    Row-major flatten:
        index(A[i][j]) = i*cols + j
    For complex=True, each element is [re, im] (np.float16).
    """
    flat = []
    for row in mat:
        for x in row:
            flat.append(x)
    return flat

def flatten_matrix_col_major(mat, complex=False):
    """
    Column-major flatten:
        index(A[i][j]) = j*rows + i
    For complex=True, each element is [re, im] (np.float16).
    """
    flat = []
    rows = len(mat)
    cols = len(mat[0])

    for c in range(cols):
        for r in range(rows):
            flat.append(mat[r][c])
    return flat

def giv_qrd(X):


if __name__ == "__main__":
    print(np.uint16(int('4dbc',16)).view(np.float16))