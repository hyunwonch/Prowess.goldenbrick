import numpy as np
from pathlib import Path
from scipy.stats import kurtosis as scipy_kurtosis
from CMAC import cadd, cmul, cdiv, binary_to_fp16, fp16_to_binary
from utils import read_binary, store_binary, generate_fp16
from typing import List
from rtl_read import read_rtl_file


def kurtosis_mapping(X, excess):
    n = len(X)
    mean = [np.float16(0.0), np.float16(0.0)]
    X_sum = [np.float16(0.0), np.float16(0.0)]
    m2_tmp = [np.float16(0.0), np.float16(0.0)]
    m2_tmpbuf = []
    var_sum = [np.float16(0.0), np.float16(0.0)]
    m4_tmp = [np.float16(0.0), np.float16(0.0)]
    m4_tmpbuf = []
    m4_sum = [np.float16(0.0), np.float16(0.0)]
    constant = [binary_to_fp16(fp16_to_binary(3.0)),binary_to_fp16(fp16_to_binary(3.0))]
    
    # 1. Obtain Mean
    for i in range(n):
        X_sum = cadd(X[i],X_sum,False)
    mean = cdiv(X_sum,[n,n])

    # mean_r = np.float16(mean[0]).view(np.uint16)
    # mean_i = np.float16(mean[1]).view(np.uint16)
    # r_hex = f"{mean_r:04x}"
    # i_hex = f"{mean_i:04x}"
    # print(r_hex,i_hex)

    # 2. Obtain Moment2
    for i in range(n):
        m2_tmp = cmul(cadd(X[i],mean,True),cadd(X[i],mean,True),False,True)
        m2_tmpbuf.append(m2_tmp)
    for i in range(n):
        var_sum = cadd(m2_tmpbuf[i],var_sum,False)
    var = cdiv(var_sum,[n,n])
    # var_r = np.float16(var[0]).view(np.uint16)
    # var_i = np.float16(var[1]).view(np.uint16)
    # var_r_hex = f"{var_r:04x}"
    # var_i_hex = f"{var_i:04x}"
    # print(var_r_hex,var_i_hex)

    # 3. Obtain Moment4
    for i in range(n):
        m4_tmp = cmul(m2_tmpbuf[i],m2_tmpbuf[i],False,True)
        m4_tmpbuf.append(m4_tmp)
    for i in range(n):
        m4_sum = cadd(m4_tmpbuf[i],m4_sum,False)
    m4 = cdiv(m4_sum,[n,n])
    # m4_r = np.float16(m4[0]).view(np.uint16)
    # m4_i = np.float16(m4[1]).view(np.uint16)
    # m4_r_hex = f"{m4_r:04x}"
    # m4_i_hex = f"{m4_i:04x}"
    # print(m4_r_hex,m4_i_hex)
    if excess:
        result = cadd(cdiv(m4,cmul(var,var,False,True)),constant,True)
    else:
        result = cdiv(m4,cmul(var,var,False,True))
   
    # result_r = np.float16(result[0]).view(np.uint16)
    # result_i = np.float16(result[1]).view(np.uint16)
    # result_r_hex = f"{result_r:04x}"
    # result_i_hex = f"{result_i:04x}"
    # print(result_r_hex,result_i_hex)
    return result

if __name__ == "__main__":
    signal_len = 128
    kernel = "kurtosis"
    path = "../PE/DATA/"
    np.random.seed(16)
    weight_cmpx = []

    x = np.random.normal(loc=0, scale=1, size=signal_len)
    y = np.random.normal(loc=0, scale=1, size=signal_len)

    k_scipy_x = scipy_kurtosis(x, fisher=True)  # fisher=True returns excess kurtosis
    print(k_scipy_x)
    k_scipy_y = scipy_kurtosis(y, fisher=True)  # fisher=True returns excess kurtosis
    print(k_scipy_y)

    x_cmpx = [[np.float16(x_real), np.float16(y_imag)] for x_real, y_imag in zip(x,y)]

    sig_length_cmpx = [np.float16(signal_len), np.float16(signal_len)]
    weight_cmpx.append(sig_length_cmpx)
    constant_cmpx = [np.float16(3), np.float16(3)]
    weight_cmpx.append(constant_cmpx)
    # print(x_cmpx)
    store_binary(x_cmpx,Path(f"{path}{kernel}_input.txt"))
    store_binary(weight_cmpx,Path(f"{path}{kernel}_weight.txt"))

    py_results = kurtosis_mapping(x_cmpx,True)
    rtl_results = read_rtl_file(Path(f"../PE/DATA/{kernel}_out.txt"))
    if kernel == "kurtosis":
        port_id = 0
        start_line = 419   # inclusive
        end_line   = 419   # inclusive

        start_idx = (start_line - 1) * 4 + port_id
        stop_idx  =  end_line * 4 + port_id   
        step      = 0                               
        rtl_capture = rtl_results[start_idx]
        r,i = py_results
        if np.isnan(r):
            r = np.inf
        elif np.isnan(i):
            i = np.inf

        if [r,i] == rtl_capture:
            print(f"\033[32m{kernel} RTL vs Py FP16 is Correct\033[0m")
            print(f"{kernel} kernel result is {py_results}, RTL output is {rtl_capture}") 
        else:
            print(f"\033[31m{kernel} RTL vs Py FP16 is Wrong\033[0m")
            print(f"{kernel} kernel result is {py_results}, RTL output is {rtl_capture}") 

         





    
