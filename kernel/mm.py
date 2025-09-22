import numpy as np
import random
from FPU import cmul, cadd
from utils import read_binary, binary_to_fp16, store_binary, generate_fp16

# ------------------------------------------------------------
# Flat (row-major) helpers
# ------------------------------------------------------------
def flatten_matrix_row_major(mat, complex=False):
    """
    Row-major flatten:
        index(A[i][j]) = i*cols + j
    For complex=True, each element is [re, im] (np.float16).
    """
    flat = []
    if complex:
        for row in mat:
            for z in row:
                flat.append([np.float16(z[0]), np.float16(z[1])])
    else:
        for row in mat:
            for x in row:
                flat.append(np.float16(x))
    return flat

def unflatten_matrix_row_major(flat, rows, cols, complex=False):
    """
    Inverse of flatten_matrix_row_major().
    Only for debugging/inspection.
    """
    mat = []
    it = iter(flat)
    if complex:
        for _ in range(rows):
            row = []
            for _ in range(cols):
                z = next(it)
                row.append([np.float16(z[0]), np.float16(z[1])])
            mat.append(row)
    else:
        for _ in range(rows):
            row = []
            for _ in range(cols):
                row.append(np.float16(next(it)))
            mat.append(row)
    return mat

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

# ------------------------------------------------------------
# Matrix multiply on FLAT (row-major) inputs/outputs
# ------------------------------------------------------------
def matrix_multiply_flat(A_flat, B_flat, M, K, N, complex=False):
    """
    Performs matrix-matrix multiplication on ROW-MAJOR flattened inputs:
        C = A x B
    A_flat: length M*K
    B_flat: length K*N
    Returns C_flat: length M*N
    - For complex=False: elements are np.float16 scalars
    - For complex=True : elements are [re, im] with np.float16 parts

    Index mapping (row-major):
        A[i,k] -> A_flat[i*K + k]
        B[k,j] -> B_flat[k*N + j]
        C[i,j] -> C_flat[i*N + j]
    """
    if not complex:
        # Real-valued fp16
        C_flat = [np.float16(0.0)] * (M * N)
        for i in range(M):
            for j in range(N):
                acc = np.float16(0.0)
                base_A = i * K
                base_C = i * N
                for k in range(K):
                    a = np.float16(A_flat[base_A + k])
                    b = np.float16(B_flat[k * N + j])
                    # Keep accumulation in fp16 to mimic ED style
                    acc = np.float16(acc + np.float16(a * b))
                C_flat[base_C + j] = acc
        return C_flat
    else:
        # Complex-valued fp16 using FPU.cmul and FPU.cadd
        # A_flat, B_flat, C_flat consist of [re, im] pairs per element.
        C_flat = [[np.float16(0.0), np.float16(0.0)] for _ in range(M * N)]
        for i in range(M):
            for j in range(N):
                acc = [np.float16(0.0), np.float16(0.0)]
                base_A = i * K
                base_C = i * N
                for k in range(K):
                    a = A_flat[base_A + k]       # [re, im]
                    b = B_flat[k * N + j]       # [re, im]
                    prod = cmul(a, b)           # [re, im]
                    acc = cadd(acc, prod)       # [re, im]
                C_flat[base_C + j] = [np.float16(acc[0]), np.float16(acc[1])]
        return C_flat

# ------------------------------------------------------------
# Example main (ED-style I/O with FLAT compute)
# ------------------------------------------------------------
if __name__ == "__main__":
    # Matrix sizes
    M = 4   # Rows in A
    K = 2   # Cols in A / Rows in B
    N = 4   # Cols in B

    use_complex = True  # Set False for real-valued matmul

    # Generate matrices (2D) then flatten row-major for storage & compute
    A_mat = generate_matrix(M, K, complex=use_complex, seed=101)
    B_mat = generate_matrix(K, N, complex=use_complex, seed=202)

    for i in A_mat:
        print(i)
    print(" ")
    for i in B_mat:
        print(i)
    print(" ")

    A_flat = flatten_matrix_row_major(A_mat, complex=use_complex)
    B_flat = flatten_matrix_row_major(B_mat, complex=use_complex)

    # Store inputs (ED style)
    store_binary(A_flat, '../PE/DATA/mm_input.txt')
    # store_binary(B_flat, '../DATA/mm_B.txt')

    # 2) Split B by columns (two columns per file), and compute outputs per pair
    pair_idx = 0
    for j in range(0, N, 2):
        # ----- Build B_pair (K x N_pair) and store as mm_{idx}_weight.txt
        selected_cols = [j] if (j + 1 >= N) else [j, j + 1]

        # Row-major within selected columns:
        # for r in 0..K-1: append B[r][j], then (if exists) B[r][j+1]
        B_pair_flat = []
        for r in range(K):
            for c in selected_cols:
                if use_complex:
                    z = B_mat[r][c]  # [re, im]
                    B_pair_flat.append([np.float16(z[0]), np.float16(z[1])])
                else:
                    B_pair_flat.append(np.float16(B_mat[r][c]))

        weight_path = f"../PE/DATA/mm_{pair_idx}_weight.txt"
        store_binary(B_pair_flat, weight_path)

        # ----- Compute C_pair = A(MxK) x B_pair(KxN_pair) on flat inputs (inline, no extra func)
        N_pair = len(selected_cols)  # 1 or 2
        if not use_complex:
            # Real path
            C_pair_flat = [np.float16(0.0)] * (M * N_pair)
            for i in range(M):
                base_A = i * K
                base_C = i * N_pair
                for jj, col in enumerate(selected_cols):
                    acc = np.float16(0.0)
                    for k in range(K):
                        a = np.float16(A_flat[base_A + k])
                        b = np.float16(B_flat[k * N + col])  # note: read from full B_flat by column index
                        acc = np.float16(acc + np.float16(a * b))
                    C_pair_flat[base_C + jj] = acc
        else:
            # Complex path
            C_pair_flat = [[np.float16(0.0), np.float16(0.0)] for _ in range(M * N_pair)]
            for i in range(M):
                base_A = i * K
                base_C = i * N_pair
                for jj, col in enumerate(selected_cols):
                    acc = [np.float16(0.0), np.float16(0.0)]
                    for k in range(K):
                        a = A_flat[base_A + k]           # [re, im]
                        b = B_flat[k * N + col]         # [re, im]
                        acc = cadd(acc, cmul(a, b))
                    C_pair_flat[base_C + jj] = [np.float16(acc[0]), np.float16(acc[1])]

        # ----- Store C_pair as mm_{idx}_output.txt (row-major within selected columns)
        # For each row i, append C[i][selected_cols[0]], then C[i][selected_cols[1]] (if exists)
        out_path = f"../PE/DATA/mm_{pair_idx}_output.txt"
        store_binary(C_pair_flat, out_path)

        print(f"Saved: {weight_path} and {out_path}")
        pair_idx += 1    # 2) Split B by columns (two columns per file), and compute outputs per pair
    pair_idx = 0
    for j in range(0, N, 2):
        # ----- Build B_pair (K x N_pair) and store as mm_{idx}_weight.txt
        selected_cols = [j] if (j + 1 >= N) else [j, j + 1]

        # Row-major within selected columns:
        # for r in 0..K-1: append B[r][j], then (if exists) B[r][j+1]
        B_pair_flat = []
        for r in range(K):
            for c in selected_cols:
                if use_complex:
                    z = B_mat[r][c]  # [re, im]
                    B_pair_flat.append([np.float16(z[0]), np.float16(z[1])])
                else:
                    B_pair_flat.append(np.float16(B_mat[r][c]))

        weight_path = f"../PE/DATA/mm_{pair_idx}_weight.txt"
        store_binary(B_pair_flat, weight_path)

        # ----- Compute C_pair = A(MxK) x B_pair(KxN_pair) on flat inputs (inline, no extra func)
        N_pair = len(selected_cols)  # 1 or 2
        if not use_complex:
            # Real path
            C_pair_flat = [np.float16(0.0)] * (M * N_pair)
            for i in range(M):
                base_A = i * K
                base_C = i * N_pair
                for jj, col in enumerate(selected_cols):
                    acc = np.float16(0.0)
                    for k in range(K):
                        a = np.float16(A_flat[base_A + k])
                        b = np.float16(B_flat[k * N + col])  # note: read from full B_flat by column index
                        acc = np.float16(acc + np.float16(a * b))
                    C_pair_flat[base_C + jj] = acc
        else:
            # Complex path
            C_pair_flat = [[np.float16(0.0), np.float16(0.0)] for _ in range(M * N_pair)]
            for i in range(M):
                base_A = i * K
                base_C = i * N_pair
                for jj, col in enumerate(selected_cols):
                    acc = [np.float16(0.0), np.float16(0.0)]
                    for k in range(K):
                        a = A_flat[base_A + k]           # [re, im]
                        b = B_flat[k * N + col]         # [re, im]
                        acc = cadd(acc, cmul(a, b))
                    C_pair_flat[base_C + jj] = [np.float16(acc[0]), np.float16(acc[1])]

        # ----- Store C_pair as mm_{idx}_output.txt (row-major within selected columns)
        # For each row i, append C[i][selected_cols[0]], then C[i][selected_cols[1]] (if exists)
        out_path = f"../PE/DATA/mm_{pair_idx}_output.txt"
        store_binary(C_pair_flat, out_path)

        print(f"Saved: {weight_path} and {out_path}")
        pair_idx += 1


    # Compute with FLAT inputs
    C_flat = matrix_multiply_flat(A_flat, B_flat, M, K, N, complex=use_complex)

    # Store output (ED style)
    store_binary(C_flat, '../PE/DATA/mm_output.txt')

    # Optional: quick print
    # (Rebuild first row of C for a human check)
    C_first_row = C_flat[0:N] if not use_complex else C_flat[0:N]
    print("A_flat (first few):", A_flat[:min(5, len(A_flat))])
    print("B_flat (first few):", B_flat[:min(5, len(B_flat))])
    print("C_first_row:", C_first_row)
