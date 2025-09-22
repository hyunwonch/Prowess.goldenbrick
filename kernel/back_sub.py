import numpy as np
from pathlib import Path
from CMAC import cadd, cmul, cdiv, binary_to_fp16, fp16_to_binary, flt2int, r_i_switch
from utils import read_binary, store_binary, generate_fp16, store_binary_1
from rtl_read import read_rtl_file

def complex_matrix_to_list(mat):
    """
    Convert a numpy complex matrix into a nested list
    where each element is [real, imag].
    """
    result = []
    for val in mat.flatten():
        result.append([np.float16(np.real(val)), np.float16(np.imag(val))])
    return result

def back_sub(R, z):
    """Back substitution for upper-triangular 4x4 complex matrix (diag real), FP16."""
    n = R.shape[0]
    x = np.zeros(n, dtype=np.complex64)
    for i in range(n-1, -1, -1):
        s = np.complex64(z[i])
        for j in range(i+1, n):
            s -= np.complex64(R[i, j]) * x[j]
        x[i] = s / np.float16(R[i, i].real)
    return x.astype(np.complex64)

def back_sub_mapping(R, z):
    n = 4
    x = []

    x4 = cdiv(z[3],cadd(R[15],r_i_switch(R[15]),sub = False))
    x.append(x4)

    x3_tmp = cadd(z[2],cmul(R[11],x4,False,False),sub = True)
    x3 = cdiv(x3_tmp,cadd(R[10],r_i_switch(R[10]),sub = False))
    x.append(x3)

    x2_tmp = cadd(z[1], cmul(x4,R[7],False,False),sub = True)
    x2_tmp = cadd(x2_tmp,cmul(x3,R[6],False,False),sub = True)
    x2 = cdiv(x2_tmp,cadd(R[5],r_i_switch(R[5]),sub = False))
    x.append(x2)

    x1_tmp = cadd(z[0], cmul(x4,R[3],False,False),sub = True)
    x1_tmp = cadd(x1_tmp,cmul(x3, R[2],False, False), sub = True)
    x1_tmp = cadd(x1_tmp,cmul(x2, R[1],False, False), sub = True)
    x1 = cdiv(x1_tmp,cadd(R[0],r_i_switch(R[0]),sub = False))
    x.append(x1)

    x.reverse()

    return x

if __name__ == "__main__":
    np.random.seed(2025)
    path = "../PE/DATA/"
    R = np.triu(np.random.randn(4,4) + 1j*np.random.randn(4,4))

    R[np.diag_indices(4)] = np.abs(R[np.diag_indices(4)])
    R = R.astype(np.complex64).astype(np.complex128)
    print("R=",R)
    x_true = (np.random.randn(4) + 1j*np.random.randn(4)).astype(np.complex64)
    z = R @ x_true

    x_est = back_sub(R.astype(np.complex64), z.astype(np.complex64))

    R_list = complex_matrix_to_list(R)
    z_list = complex_matrix_to_list(z)

    x_map = back_sub_mapping(R_list,z_list)
    print("x_map =",x_map)

    print("x_true =", x_true)
    print("x_est  =", x_est)
    print("error  =", np.linalg.norm(x_true - x_est))
    print("R_list  =", R_list)
    print("z_list  =", z_list)

    z_list.reverse()
    back_sub1_input = R_list + z_list
    # print(back_sub1_input)
    store_binary_1(back_sub1_input, Path(f"{path}back_sub1_input.txt"))



    r_11 = cadd(R_list[0],r_i_switch(R_list[0]),False)
    r_22 = cadd(R_list[5],r_i_switch(R_list[5]),False)

    back_sub2_input = R_list
    back_sub2_input.append(x_map[3])
    back_sub2_input.append(x_map[2])
    back_sub2_input.append(r_22)
    back_sub2_input.append(r_11)
    back_sub2_input.append(z_list[2])
    back_sub2_input.append(z_list[3])
    store_binary_1(back_sub2_input, Path(f"{path}back_sub2_input.txt"),zero_padding = 2, mid_zeros={16:41})

    num = 0x2b34
    print('num =',binary_to_fp16(format(num, '016b')))

    # Test
    kernel = "back_sub1"
    rtl_results = read_rtl_file(Path(f"../PE/DATA/{kernel}_out.txt"))

    if kernel == "back_sub1":
        py_results = back_sub2_input[-6:]
        port_id = 0
        start_line = 608   # inclusive
        end_line   = 613   # inclusive

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

    elif kernel == "back_sub2":
        py_results = x_map
        port_id = 0
        start_line = 639   # inclusive
        end_line   = 642   # inclusive

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


