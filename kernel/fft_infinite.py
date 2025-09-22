
import numpy as np
import random
import os
import sys

def read_binary(filename):
    with open(filename, 'r') as file:
        lines = file.readlines()

    parsed_lines = []

    for line in lines:
        line = line.strip().replace(" ", "")  # 공백 제거
        n_bits = len(line)

        if n_bits % 32 != 0:
            raise ValueError(f"Invalid bit length in line: {line} (not a multiple of 32)")

        n_complex = n_bits // 32
        complex_vals = []

        for i in range(n_complex):
            # 32bit chunk: [real|imag]
            chunk = line[i*32 : (i+1)*32]
            real_bin = chunk[0:16]
            imag_bin = chunk[16:32]
            complex_vals.append([real_bin, imag_bin])

        if n_complex == 1:
            parsed_lines.append([real_bin, imag_bin])
        else:
            parsed_lines.append(complex_vals)

    return parsed_lines

def binary_to_fp16(binary_array):
    float16_array = []

    # print(len(binary_array), "complex numbers found in the file.")
    for line in binary_array:
        complex_line = []
        # print(len(line[0]))
        if(len(line[0]) == 16):
            # Single complex number case
            real_fp16 = np.uint16(int(line[0], 2)).view(np.float16)
            imag_fp16 = np.uint16(int(line[1], 2)).view(np.float16)
            complex_line.append([real_fp16, imag_fp16])
        else:
            for real, imag in line:
                if(real == "xxxxxxxxxxxxxxxx"):
                    real = "1" * 16
                if(imag == "xxxxxxxxxxxxxxxx"):
                    imag = "1" * 16
                real_fp16 = np.uint16(int(real, 2)).view(np.float16)
                imag_fp16 = np.uint16(int(imag, 2)).view(np.float16)
                complex_line.append([real_fp16, imag_fp16])
        float16_array.append(complex_line)

    return float16_array

DATA_PATH = "/net/badwater/z/hyunwon/Documents/_GIT/PROWESS/SIM/PE/DATA/"
OUTPUT_PATH = "/net/badwater/z/hyunwon/Documents/TSMC_Prowess/sim/PE/OUTPUT/"

# kernel_list2 = ['fft_0', 'fft_1', 'fft_2', 'fft_3', 'fft_4', 'fft_5', 'fft_6', 'fft_7']
kernel_list = ['fft_infinite_0', 'fft_infinite_1', 'fft_infinite_2', 'fft_infinite_3', 'fft_infinite_4', 'fft_infinite_5', 'fft_infinite_6', 'fft_infinite_7']
# kernel_list = ['fft_5']

for kernel in kernel_list:
    golden_kernel = kernel.replace("infinite_", "")

    golden = binary_to_fp16(read_binary(DATA_PATH + golden_kernel + "_output.txt"))
    result = (binary_to_fp16(read_binary(OUTPUT_PATH + kernel + "_out2.txt")))
    j = 0
    if(kernel == 'fft_infinite_7'):
        start = 551 + 50 + 37 + 69 + 133
    elif(kernel == 'fft_infinite_6'):
        start = 551 + 50 + 37 + 69
    elif (kernel == 'fft_infinite_5'):
        start = 551 + 50 + 37
    elif (kernel == 'fft_infinite_4'):
        # start = 69-32-16
        start = 551 + 50
    elif (kernel == 'fft_infinite_3'):
        # start = 69-32-16-8
        start = 551 + 29
    elif (kernel == 'fft_infinite_2'):
        start = 551 + 16
    elif (kernel == 'fft_infinite_1'):
        # start = 69-32-16-8-4-2
        start = 551 + 7
    elif (kernel == 'fft_infinite_0'):
        # start = 69-32-16-8-4-2-3
        start = 551
    # print(start)
    error = 0
    for i in range(start, start+256):
        if(result[i][1] != golden[j][0]):
            print(j, result[i][1], golden[j][0], result[i][1] == golden[j][0])
            error =1
            print("-----------------------------------------------WRONG----------------------------------------------------")
        j += 1
    print(f'{kernel} : ', error)