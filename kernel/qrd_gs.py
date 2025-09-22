import numpy as np
import sys
from pathlib import Path
from CMAC import cadd, cmul, cdiv, binary_to_fp16, fp16_to_binary, flt2int
from utils import read_binary, store_binary, generate_fp16, store_binary_1
from typing import List, Tuple, Union
from rtl_read import read_rtl_file
from cordic import cordic

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

def r_i_switch(a):

    z = [a[1],a[0]]

    return z

def conj(a):

    z = [a[0],-a[1]]

    return z

def list3_to_complex_ndarray(A_list3: List[List[List[float]]], work_dtype=np.complex64) -> np.ndarray:
    """
    Convert [[[re, im], ...], ...] to a 2-D complex ndarray of shape (m, n).
    """
    A_arr = np.array(A_list3, dtype=np.float32)  # shape (m, n, 2)
    if A_arr.ndim != 3 or A_arr.shape[-1] != 2:
        raise ValueError("Expect a 3-D list/array with last dim = 2 (re, im).")
    real = A_arr[..., 0]
    imag = A_arr[..., 1]
    A = (real + 1j * imag).astype(work_dtype, copy=False)  # (m, n)
    return A

def complex_ndarray_to_list3(M: np.ndarray) -> List[List[List[float]]]:
    """
    Convert a 2-D complex ndarray (m, n) to [[[re, im], ...], ...].
    """
    if M.ndim != 2:
        raise ValueError("Expect a 2-D complex ndarray.")
    m, n = M.shape
    out = [[[float(M[r, c].real), float(M[r, c].imag)] for c in range(n)] for r in range(m)]
    return out

# ---------- MGS-QR for 3-D list format ----------

def mgs_qr(A_list3: List[List[List[float]]],
                 work_dtype=np.complex64,
                 out_as_list3: bool = True
                ) -> Tuple[Union[np.ndarray, List[List[List[float]]]],
                           Union[np.ndarray, List[List[List[float]]]]]:
    """
    Modified Gram¨CSchmidt QR where input is [[[re, im], ...], ...] (shape m¡Án¡Á2).
    Returns Q (m¡Án) and R (n¡Án) in the same format if out_as_list3=True.
    """
    # 1) convert to complex ndarray
    A = list3_to_complex_ndarray(A_list3, work_dtype=work_dtype)
    m, n = A.shape

    # 2) MGS
    Q = np.zeros((m, n), dtype=work_dtype)
    R = np.zeros((n, n), dtype=work_dtype)
    V = A.copy()

    for i in range(n):
        # diag
        R[i, i] = np.linalg.norm(V[:, i])
        if R[i, i] == 0:
            Q[:, i] = 0
            continue
        Q[:, i] = V[:, i] / R[i, i]

        # compute the whole row r_{i, i:} and subtract immediately (MGS)
        if i+1 < n:
            # 1¡Á(n-i-1) row of coefficients
            r_row = Q[:, i].conj().T @ V[:, i+1:]          # shape (n-i-1,)
            R[i, i+1:] = r_row
            V[:, i+1:] -= np.outer(Q[:, i], r_row)         # immediate update

    # 3) convert back if needed
    if out_as_list3:
        Q_list3 = complex_ndarray_to_list3(Q)
        R_list3 = complex_ndarray_to_list3(R)  # R is complex but its diagonal is real¡Ý0
        return Q_list3, R_list3
    else:
        return Q, R

def mgs_qr_mapping(A, row_len, col_len):
    n = len(A)
    A1 = A[0:col_len]
    A11_norm = cordic(flt2int(A1[0][0]),flt2int(A1[0][1]),0,2,True)
    # print("A11_norm =", A11_norm)
    A21_norm = cordic(flt2int(A1[1][0]),flt2int(A1[1][1]),0,2,True)
    # print("A21_norm =", A21_norm)
    A31_norm = cordic(flt2int(A1[2][0]),flt2int(A1[2][1]),0,2,True)
    # print("A31_norm =", A31_norm)
    A41_norm = cordic(flt2int(A1[3][0]),flt2int(A1[3][1]),0,2,True)
    # print("A41_norm =", A41_norm)

    a1_12_sum = cadd(r_i_switch(A11_norm),A21_norm,False)
    a1_12_norm = cordic(flt2int(a1_12_sum[0]),flt2int(a1_12_sum[1]),0,2,True)
    # print("a1_12_sum =",a1_12_sum,"a1_12_norm =",a1_12_norm)

    a1_34_sum = cadd(r_i_switch(A31_norm),A41_norm,False)
    a1_34_norm = cordic(flt2int(a1_34_sum[0]),flt2int(a1_34_sum[1]),0,2,True)
    # print("a1_34_sum =",a1_34_sum,"a1_34_norm =",a1_34_norm)

    a1_sum = cadd(r_i_switch(a1_12_norm),a1_34_norm,False)
    a1_norm = cordic(flt2int(a1_sum[0]),flt2int(a1_sum[1]),0,2,True)
    # print("a1_sum =",a1_sum,"a1_norm =",a1_norm)

    # The next part will be passed to the Divider PE and completed with qrd_gs2.s
    # Do the divide to get the q1, then do the matrix multiplication to get r1,j
    # Do the sub to get the A1 after computation
    r11 = a1_norm
    r11_div = cadd(r11,r_i_switch(r11),False) # The real and imag all divide the real part of diagnoal element
    q1 = []
    for i in range(col_len):
        q1_tmp = cdiv(A1[i],r11_div)
        q1.append(q1_tmp)
    # print(f"q1 = {q1}")

    # For a complex matrix, to calculate the r_ij, we need to use the conjugate transpose matrix
    # to do the calculation
    r1_row = []
    r1_row.append(r11)
    r1_row_tmp = [np.float16(0.0), np.float16(0.0)]
    for j in range(1,col_len):
        for i in range(col_len):
            r1_row_tmp = cadd(r1_row_tmp, cmul(conj(q1[i]),A[4*j+i],False,False), False)
        r1_row.append(r1_row_tmp)
        r1_row_tmp = [np.float16(0.0), np.float16(0.0)]
    # print("r1_row =",r1_row)


    # Calculate A_1 of the origin matrix A after the first calculation
    A_1 = [[np.float16(0.0), np.float16(0.0)] for __ in range(row_len*col_len)]

    for j in range(1,col_len):
        for i in range(row_len):
            A_1[4*j+i] = cadd(A[4*j+i],cmul(r1_row[j],q1[i],False,False),True)

    # print("A_1=",A_1)

    # Used for the PE5 calculation: A1_inter
    A1_inter = [[np.float16(0.0), np.float16(0.0)] for __ in range(row_len*col_len)]
    for j in range(col_len):
        for i in range(row_len):
            A1_inter[4*j+i] = cmul(r1_row[j],q1[i],False,False)
    # print("A1_inter=",A1_inter)


    return r11, q1, r1_row, A_1, A1_inter

def mgs_qr_mapping_gen(A, row_len, col_len, num):

    a_norm = [[np.float16(0.0), np.float16(0.0)] for __ in range(col_len)]
    for i in range(col_len):
        a_norm[i] = cordic(flt2int(A[num*4+i][0]),flt2int(A[num*4+i][1]),0,2,True)
        # print(A[num*4+i])
    print(f"a{num+1}_norm =\n",a_norm)

    a_12_sum = cadd(r_i_switch(a_norm[0]),a_norm[1],False)
    a_12_norm = cordic(flt2int(a_12_sum[0]),flt2int(a_12_sum[1]),0,2,True)
    print(f"a{num+1}_12_sum =",a_12_sum,"a_12_norm =",a_12_norm)

    a_34_sum = cadd(r_i_switch(a_norm[2]),a_norm[3],False)
    a_34_norm = cordic(flt2int(a_34_sum[0]),flt2int(a_34_sum[1]),0,2,True)
    print("a_34_sum =",a_34_sum,"a_34_norm =",a_34_norm)

    a_sum = cadd(r_i_switch(a_12_norm),a_34_norm,False)
    a_norm = cordic(flt2int(a_sum[0]),flt2int(a_sum[1]),0,2,True)
    print("a_sum =",a_sum,"a_norm =",a_norm)

    r_jj = a_norm
    r_jj_div = cadd(r_jj,r_i_switch(r_jj),False) # The real and imag all divide the real part of diagnoal element
    q_j = []
    for i in range(col_len):
        q_j_tmp = cdiv(A[num*4+i],r_jj_div)
        q_j.append(q_j_tmp)

    r_row = [[np.float16(0.0),np.float16(0.0)] for __ in range(num)]

    r_row.append(r_jj)
    r_row_tmp = [np.float16(0.0), np.float16(0.0)]
    for j in range(num+1,col_len):
        for i in range(col_len):
            r_row_tmp = cadd(r_row_tmp, cmul(conj(q_j[i]),A[4*j+i],False,False), False)
        r_row.append(r_row_tmp)
        r_row_tmp = [np.float16(0.0), np.float16(0.0)]
    print(f"r_row_{num+1} =",r_row)

    # Calculate A_1 of the origin matrix A after the first calculation
    Ap = [[np.float16(0.0), np.float16(0.0)] for __ in range(row_len*col_len)]

    for j in range(num+1,col_len):
        for i in range(row_len):
            Ap[4*j+i] = cadd(A[4*j+i],cmul(r_row[j],q_j[i],False,False),True)

    print(f"A_{num+1}=\n",Ap)

    # Used for the PE5 calculation: A1_inter
    Ap_inter = [[np.float16(0.0), np.float16(0.0)] for __ in range(row_len*col_len)]
    for j in range(col_len):
        for i in range(row_len):
            Ap_inter[4*j+i] = cmul(r_row[j],q_j[i],False,False)
    print(f"A{num+1}_inter=\n",Ap_inter)


    return r_jj, q_j, r_row, Ap, Ap_inter


if __name__ == "__main__":
    signal_len = 16
    path = "../PE/DATA/"
    A = np.array([[1+1j, 2+0j, 3-1j, 1+2j],
                [3+4j, 1-1j, 1+0j, 2+0j],
                [2+0j, -1+1j, 0+2j, 1-1j],
                [1-1j, 2+1j, 1+1j, 0+1j]], dtype=complex)

    Q_ref, R_ref = np.linalg.qr(A)

    A_list = [[[1.0, 1.0], [2.0, 0.0], [3.0,-1.0], [1.0, 2.0]],
              [[3.0, 4.0], [1.0, -1.0], [1.0,0.0], [2.0, 0.0]],
              [[2.0, 0.0], [-1.0, 1.0], [0.0,2.0], [1.0, -1.0]],
              [[1.0, -1.0], [2.0, 1.0], [1.0,1.0], [0.0, 1.0]]
              ]
    Q, R = mgs_qr(A_list)


    A_col_flatten = flatten_matrix_col_major(A_list, complex=True)
    r11, q1, r1_row, A_1, A1_inter = mgs_qr_mapping(A_col_flatten, 4, 4)
    q1_conj = []
    for i in range(len(q1)):
        q1_conj.append(conj(q1[i]))


    # B = generate_matrix(4, 4, complex=True, seed=2)
    # B_col = flatten_matrix_col_major(B, complex=True)
    # print("B =",B)
    # print("B_col_flatten = ",B_col)


    # print("Q =\n", Q)
    # print("\nR =\n", R)
    # print("\n||Q^H Q - I|| =", I_err)
    # print("||Q R - A||   =", recon_err)

    print("Q_ref = \n:", Q_ref)
    print("R_ref = \n:", R_ref)
    r_22, q2, r2_row, A2, A2_inter = mgs_qr_mapping_gen(A_1,4,4,1)
    r_33, q3, r3_row, A3, A3_inter = mgs_qr_mapping_gen(A2,4,4,2)
    r_44, q4, r4_row, A4, A4_inter = mgs_qr_mapping_gen(A3,4,4,3)
    q2_conj = []
    q3_conj = []
    q4_conj = []
    for i in range(4):
        q2_conj.append(conj(q2[i]))
        q3_conj.append(conj(q3[i]))
        q4_conj.append(conj(q4[i]))


    R_map = r1_row + r2_row + r3_row + r4_row
    Q_map = q1 + q2 + q3 + q4

    PE_delay = 2
    SW_delay = 1
    PE1_exe = 39
    PE2_exe = 12
    PE3_exe = 33
    PE4_exe = 9
    PE5_exe = 2
    PE6_Ap_exe = 19
    PE6_ap_j_exe = 36



    # FOR QRD_GS1
    a1_2 = A_1[4:8] # Come from Input Port 0
    a2_3 = A2[8:12] # Come from Input Port 0
    a3_4 = A3[12:16] # Come from Input Port 0
    gs1_input = A_col_flatten[0:4] + a1_2 + a2_3 + a3_4
    store_binary_1(gs1_input, Path(f"{path}qrd_gs1_input.txt"),
                            zero_padding = 15,
                            mid_zeros={4:156,
                                       8:156,
                                       12:156})

    # FOR QRD_GS2
    gs2_input = A_col_flatten[0:4]  # Come from Input Port 0
    gs2_input.append(r11) #4 Come from Input Port 1
    gs2_input.extend(a1_2) #5 Come from Input Port 1
    gs2_input.append(r_22) #9 Come from Input Port 1
    gs2_input.extend(a2_3) #10 Come from Input Port 1
    gs2_input.append(r_33) #14 Come from Input Port 1
    gs2_input.extend(a3_4) #15 Come from Input Port 1
    gs2_input.append(r_44) #19 Come from Input Port 1
    store_binary_1(gs2_input, Path(f"{path}qrd_gs2_input.txt"),
                                mid_zeros={4:63,
                                           5:116,
                                           9:39,
                                           10:116,
                                           14:39,
                                           15:116,
                                           19:39})

    # FOR QRD_GS3
    gs3_input = list(A_col_flatten) # Come from Input Port 0
    gs3_input.extend(q1_conj) #16 Come from Input Port 0
    gs3_input.extend(A_1) #20 Come from Input Port 1
    gs3_input.extend(q2_conj) #36 Come from Input Port 0
    gs3_input.extend(A2) #40 Come from Input Port 1
    gs3_input.extend(q3_conj) #56 Come from Input Port 0
    gs3_input.extend(A3) #60 Come from Input Port 1

    # print("gs3_input",gs3_input)
    store_binary_1(gs3_input, Path(f"{path}qrd_gs3_input.txt"),
                                zero_padding = (PE_delay*1 + SW_delay*1),
                                mid_zeros={16:(PE_delay*5 + SW_delay*5 + PE1_exe + PE_delay*4 + SW_delay*5 + PE2_exe + SW_delay)-16-3,
                                           20:80,
                                           36:60,
                                           40:80,
                                           56:60,
                                           60:80})

    # FOR QRD_GS4
    gs4_input = list(q1_conj) # Come from input port 0
    gs4_input.extend(r1_row) #4 Come from input port 0
    gs4_input.extend(q2_conj) #8 Come from input port 0
    gs4_input.extend(r2_row) #12 Come from input port 0
    gs4_input.extend(q3_conj) #16 Come from input port 0
    gs4_input.extend(r3_row) #20 Come from input port 0
    store_binary_1(gs4_input, Path(f"{path}qrd_gs4_input.txt"),
                                        zero_padding = 83,
                                        mid_zeros={4:38,
                                                   8:114,
                                                   12:38,
                                                   16:114,
                                                   20:38})

    # FOR QRD_GS5
    gs5_input = list(A_col_flatten) # Come from input port 0
    gs5_input.extend(A1_inter) #16 Come from input port 0
    gs5_input.extend(A_1) #32 Come from input port 0
    gs5_input.extend(A2_inter) #48 Come from input port 0
    gs5_input.extend(A2) #64 Come from input port 0
    gs5_input.extend(A3_inter) #80 Come from input port 0
    # print("gs5_input=\n",gs5_input)
    store_binary_1(gs5_input, Path(f"{path}qrd_gs5_input.txt"), zero_padding = 9, mid_zeros={16:110, 32:7, 48:121, 64:7, 80:121})

    # FOR QRD_GS6
    gs6_input = list(A_1) # Come from input port 0
    gs6_input.extend(A2) #16 Come from input port 0
    gs6_input.extend(A3) #32 Come from input port 0

    store_binary_1(gs6_input, Path(f"{path}qrd_gs6_input.txt"), zero_padding = 138, mid_zeros={16:144, 32:144})

    # FOR QRD_GS7
    r_jj_row = [r11, r_22, r_33, r_44]
    gs7_input = list(r1_row[1:])
    gs7_input.extend(r2_row[2:]) #3 Come from input port 0
    gs7_input.extend(r3_row[3:]) #5 Come from input port 0
    gs7_input.extend(r_jj_row) #6 Come from input port 0
    store_binary_1(gs7_input, Path(f"{path}qrd_gs7_input.txt"), zero_padding = 126, mid_zeros={3:158, 5:159, 6:212})




    print("Q =\n", Q)
    print("\nR =\n", R)
    print("Q_map = \n",Q_map)
    print("R_map = \n",R_map)

    print('a1_12=',binary_to_fp16('0100010100111001'))
    # print("gs2=",gs2_input)
    # Results Compare
    kernel = "qrd_gs1"
    rtl_results = read_rtl_file(Path(f"../PE/DATA/{kernel}_out.txt"))

    if kernel == "qrd_gs1":

        py_results = [r11, r_22, r_33, r_44]
        port_id = 3
        step    = 4

        start_line = 1207   # inclusive
        end_line   = 1210   # inclusive

        start_idx = (start_line - 1) * 4 + port_id
        stop_idx  =  end_line * 4 + port_id
        step      = 4
        rtl_capture = rtl_results[start_idx : stop_idx : step]

        if len(rtl_capture) != len(py_results):
            print(f"\033[31m{kernel} capture range is Wrong\033[0m")
            sys.exit()

        # print(rtl_capture)
        dif_cnt = 0
        for i, (pyt, rtl) in enumerate(zip(py_results, rtl_capture)):
            if not np.array_equal(pyt, rtl):
                dif_cnt += 1
                print(f"\033[31m{kernel} has different result at {i}\033[0m")
                print(f"{kernel} kernel result is {py_results[i]}, RTL output is {rtl_capture[i]}")
        if dif_cnt == 0:
            print(f"\033[32m{kernel} RTL vs Py FP16 is Correct\033[0m")
        else:
            print(f"\033[31m{kernel} has {dif_cnt} different results\033[0m")

    elif kernel == "qrd_gs2":
        py_results = Q_map
        port_id = 0
        start_line = 1261   # inclusive
        end_line   = 1276   # inclusive

        start_idx = (start_line - 1) * 4 + port_id
        stop_idx  =  end_line * 4 + port_id
        step      = 4
        rtl_capture = rtl_results[start_idx : stop_idx : step]
        if len(rtl_capture) != len(py_results):
            print(f"\033[31m{kernel} capture range is Wrong\033[0m")
        # print(rtl_capture)
        dif_cnt = 0
        for i, (pyt, rtl) in enumerate(zip(py_results, rtl_capture)):
            if not np.array_equal(pyt, rtl):
                dif_cnt += 1
                print(f"\033[31m{kernel} has different result at {i}\033[0m")
                print(f"{kernel} kernel result is {py_results[i]}, RTL output is {rtl_capture[i]}")
        if dif_cnt == 0:
            print(f"\033[32m{kernel} RTL vs Py FP16 is Correct\033[0m")
        else:
            print(f"\033[31m{kernel} has {dif_cnt} different results\033[0m")

    elif kernel == "qrd_gs4":
        py_results = A1_inter + A2_inter + A3_inter
        port_id = 1
        step    = 4

        # A1_inter, A2_inter, A3_inter
        start_line_1, end_line_1 = 684, 699   # inclusive
        start_line_2, end_line_2 = 844, 859
        start_line_3, end_line_3 = 1004, 1019

        segments = [
        (start_line_1, end_line_1),
        (start_line_2, end_line_2),
        (start_line_3, end_line_3),
        ]

        rtl_capture = []
        for s_line, e_line in segments:
            s_idx = (s_line - 1) * step + port_id
            e_idx =  e_line      * step + port_id
            rtl_capture.extend(rtl_results[s_idx:e_idx:step])

        if len(rtl_capture) != len(py_results):
            print(f"\033[31m{kernel} capture range is Wrong, rtl is {len(rtl_capture)}, py is {len(py_results)}\033[0m")
        # print(rtl_capture)
        dif_cnt = 0
        for i, (pyt, rtl) in enumerate(zip(py_results, rtl_capture)):
            if not np.array_equal(pyt, rtl):
                dif_cnt += 1
                print(f"\033[31m{kernel} has different result at {i}\033[0m")
                print(f"{kernel} kernel result is {py_results[i]}, RTL output is {rtl_capture[i]}")
        if dif_cnt == 0:
            print(f"\033[32m{kernel} RTL vs Py FP16 is Correct\033[0m")
        else:
            print(f"\033[31m{kernel} has {dif_cnt} different results\033[0m")

    elif kernel == "qrd_gs5":
        py_results = A_1 + A2 + A3
        port_id = 1
        step    = 4

        # A1, A2, A3
        start_line_1, end_line_1 = 687, 702   # inclusive
        start_line_2, end_line_2 = 847, 862
        start_line_3, end_line_3 = 1007, 1022

        segments = [
        (start_line_1, end_line_1),
        (start_line_2, end_line_2),
        (start_line_3, end_line_3),
        ]

        rtl_capture = []
        for s_line, e_line in segments:
            s_idx = (s_line - 1) * step + port_id
            e_idx =  e_line      * step + port_id
            rtl_capture.extend(rtl_results[s_idx:e_idx:step])


        if len(rtl_capture) != len(py_results):
            print(f"\033[31m{kernel} capture range is Wrong, rtl is {len(rtl_capture)}, py is {len(py_results)}\033[0m")
        # print(rtl_capture)
        dif_cnt = 0
        for i, (pyt, rtl) in enumerate(zip(py_results, rtl_capture)):
            if not np.array_equal(pyt, rtl):
                dif_cnt += 1
                print(f"\033[31m{kernel} has different result at {i}\033[0m")
                print(f"{kernel} kernel result is {py_results[i]}, RTL output is {rtl_capture[i]}")
        if dif_cnt == 0:
            print(f"\033[32m{kernel} RTL vs Py FP16 is Correct\033[0m")
        else:
            print(f"\033[31m{kernel} has {dif_cnt} different results\033[0m")

    elif kernel == "qrd_gs6":
        py_results = A_1 + a1_2 + A2 + a2_3 + A3 + a3_4
        port_id = 0
        step    = 4

        # A1_inter, A2_inter, A3_inter
        start_line_1, end_line_1 = 707, 722   # inclusive
        start_line_2, end_line_2 = 724, 727
        start_line_3, end_line_3 = 867, 882
        start_line_4, end_line_4 = 884, 887
        start_line_5, end_line_5 = 1027, 1042
        start_line_6, end_line_6 = 1044, 1047

        segments = [
        (start_line_1, end_line_1),
        (start_line_2, end_line_2),
        (start_line_3, end_line_3),
        (start_line_4, end_line_4),
        (start_line_5, end_line_5),
        (start_line_6, end_line_6),

        ]

        rtl_capture = []
        for s_line, e_line in segments:
            s_idx = (s_line - 1) * step + port_id
            e_idx =  e_line      * step + port_id
            rtl_capture.extend(rtl_results[s_idx:e_idx:step])


        if len(rtl_capture) != len(py_results):
            print(f"\033[31m{kernel} capture range is Wrong, rtl is {len(rtl_capture)}, py is {len(py_results)}\033[0m")
        # print(rtl_capture)
        dif_cnt = 0
        for i, (pyt, rtl) in enumerate(zip(py_results, rtl_capture)):
            if not np.array_equal(pyt, rtl):
                dif_cnt += 1
                print(f"\033[31m{kernel} has different result at {i}\033[0m")
                print(f"{kernel} kernel result is {py_results[i]}, RTL output is {rtl_capture[i]}")
        if dif_cnt == 0:
            print(f"\033[32m{kernel} RTL vs Py FP16 is Correct\033[0m")
        else:
            print(f"\033[31m{kernel} has {dif_cnt} different results\033[0m")

    elif kernel == "qrd_gs7":
        py_results = R_map
        port_id = 0
        start_line = 1218   # inclusive
        end_line   = 1233   # inclusive

        start_idx = (start_line - 1) * 4 + port_id
        stop_idx  =  end_line * 4 + port_id
        step      = 4
        rtl_capture = rtl_results[start_idx : stop_idx : step]
        if len(rtl_capture) != len(py_results):
            print(f"\033[31m{kernel} capture range is Wrong\033[0m")
        # print(rtl_capture)
        dif_cnt = 0
        for i, (pyt, rtl) in enumerate(zip(py_results, rtl_capture)):
            if not np.array_equal(pyt, rtl):
                dif_cnt += 1
                print(f"\033[31m{kernel} has different result at {i}\033[0m")
                print(f"{kernel} kernel result is {py_results[i]}, RTL output is {rtl_capture[i]}")
        if dif_cnt == 0:
            print(f"\033[32m{kernel} RTL vs Py FP16 is Correct\033[0m")
        else:
            print(f"\033[31m{kernel} has {dif_cnt} different results\033[0m")




