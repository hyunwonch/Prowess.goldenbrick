import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path
from scipy.signal import hilbert as hilbert_scipy
from CMAC import cadd, cmul, binary_to_fp16, fp16_to_binary
from utils import read_binary, store_binary, generate_fp16
from typing import List
from rtl_read import read_rtl_file
# -----------------------------------------------------------
# Hilbert Transform using time-domain convolution
# -----------------------------------------------------------

def hilbert_manual_conv(x, filter_len=128):
    x = np.asarray(x)

    # Only apply to real part if complex input
    x_real = np.real(x)

    if filter_len % 2 == 0:
        filter_len += 1

    n = np.arange(-(filter_len // 2), filter_len // 2 + 1)
    h = np.zeros_like(n, dtype=np.float64)
    for i, ni in enumerate(n):
        if ni == 0 or ni % 2 == 0:
            h[i] = 0.0
        else:
            h[i] = 2 / (np.pi * ni)
    x_padded = np.pad(x_real, (filter_len // 2, filter_len // 2), mode='reflect')
    x_hilbert = np.convolve(x_padded, h, mode='valid')

    # Reconstruct analytic signal: real + j·hilbert
    z = x_real + 1j * x_hilbert
    return x_padded, h, z, x_hilbert

# Use our's FPU to do the algorithm mapping
def hilbert_mapping(sig_in, filter_in):
    fil = filter_in
    left_pad = sig_in[1:len(fil)//2+1][::-1]
    right_pad = sig_in [-(len(fil)//2+1):-1][::-1]
    x_real = left_pad + sig_in + right_pad
    results = []
    tmp = [np.float16(0.0), np.float16(0.0)]
    for i in range(len(x_real) - len(fil) + 1):
        for j in range(len(fil)):
            # if i == 0:
            #     print(f"\033[32m{j:>4} cycle\033[0m")
            #     print(f"opa: {tmp[0]:>10.5f} | "f"opa_binary: {format(int(fp16_to_binary(tmp[0]),2),'04x')}")
            #     print(f"opb: {cmul(x_real[i+j], fil[len(fil)-j-1], False, False)[0]:>10.5f} | "f"opb_binary: {format(int(fp16_to_binary(cmul(x_real[i+j], fil[len(fil)-j-1], False, False)[0]),2),'04x')}")
            tmp = cadd (cmul(x_real[i+j],fil[len(fil)-j-1],False,False),tmp,False)
        results.append([tmp[0], tmp[1]])
        tmp = [np.float16(0.0), np.float16(0.0)]
    return results

# -----------------------------------------------------------
# Generate test signal (real and complex part)
# -----------------------------------------------------------
if __name__ == "__main__":
    signal_len = 64
    filter_len = 16
    kernel = "hilbert"
    path = "../PE/DATA/"


    t = np.linspace(0, 1, signal_len, endpoint=False)
    x_real = np.cos(2 * np.pi * 5 * t)
    x_imag = 0.5 * np.sin(2 * np.pi * 10 * t)
    x = x_real + 1j * x_imag  # Can also test with just real signal

    # just do the test
    # t = np.linspace(0, signal_len, signal_len, endpoint=False)
    # x_real = np.float16(t)
    # x_imag = np.float16(t)
    # x = x_real + 1j*x_imag

    x_padded, h, analytic_conv, x_hilbert = hilbert_manual_conv(x, filter_len=filter_len)
    x_cmpx = [[x, 0.0] for x in x_real]
    h = [[coe, 0.0] for coe in h]
    store_binary(h,Path(f"{path}{kernel}_weight.txt"))
    store_binary(x_cmpx,Path(f"{path}{kernel}_input.txt"))
    py_results = hilbert_mapping(x_cmpx,h)
    # print(x_hilbert)
    # print(len(x_hilbert))
    # print(py_results)
    # print(len(py_results))
    diff = []
    hilbert_our = [a for [a,b] in py_results]
    err_cnt = 0
    eps = 1e-12
    for i in range(len(x_hilbert)):
        err = x_hilbert[i] - hilbert_our[i]
        abs_err = np.abs(err)
        rel_err = abs_err / (np.abs(x_hilbert[i]) + eps)
        if rel_err >= (filter_len + 1)* 0.0005:
            print(f"Big Error at {i}")
            print(f"FP64:{x_hilbert[i]} | FP16:{hilbert_our[i]}")
            err_cnt += 1
        diff.append(err)

    if err_cnt == 0:
        print("\033[032mFP16 and FP64 Match\033[0m")
    else:
        print(f"\033[031mPy FP16 vs FP64 Has {err_cnt} diff\033[0m")

    rtl_results = read_rtl_file(Path(f"../PE/DATA/{kernel}_out.txt"))
    if kernel == "hilbert":
        port_id = 0
        start_line = 1499   # inclusive
        end_line   = 1562   # inclusive

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




