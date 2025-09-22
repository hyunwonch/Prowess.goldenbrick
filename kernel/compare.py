import numpy as np
import sys
import os


def read_binary(filename):
    with open(filename, 'r') as file:
        lines = file.readlines()

    parsed_lines = []

    for line in lines:
        line = line.strip().replace(" ", "")
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

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script.py <kernel_name>")
        sys.exit(1)

    kernel = sys.argv[1]

    DATA_PATH = "/net/badwater/z/hyunwon/Documents/_GIT/PROWESS/SIM/PE/DATA/"
    OUTPUT_PATH = "/net/badwater/z/hyunwon/Documents/TSMC_Prowess/sim/PE/OUTPUT/"

    # kernel
    kernel_config = {
        "fft_7":    {"start": 551 + 50 + 37 + 69 + 133, "length": 256,  "output":1},
        "fft_6":    {"start": 551 + 50 + 37 + 69,       "length": 256,  "output":1},
        "fft_5":    {"start": 551 + 50 + 37,            "length": 256,  "output":1},
        "fft_4":    {"start": 551 + 50,                 "length": 256,  "output":1},
        "fft_3":    {"start": 551 + 29,                 "length": 256,  "output":1},
        "fft_2":    {"start": 551 + 16,                 "length": 256,  "output":1},
        "fft_1":    {"start": 551 + 7,                  "length": 256,  "output":1},
        "fft_0":    {"start": 551,                      "length": 256,  "output":1},
        "kurtosis": {"start": 1672,                     "length": 1,    "output":1},
        "ed":       {"start": 679,                      "length": 1,    "output":1},
        "mm_0":     {"start": 681,                      "length": 2,    "output":3},
        "mm_1":     {"start": 681,                      "length": 2,    "output":3},
        "mm_2":     {"start": 682,                      "length": 2,    "output":3},
        "mm_3":     {"start": 683,                      "length": 2,    "output":3},
        "mm_4":     {"start": 684,                      "length": 2,    "output":3},
        "mm_5":     {"start": 685,                      "length": 2,    "output":3},
        "mm_6":     {"start": 686,                      "length": 2,    "output":3},
        "mm_7":     {"start": 687,                      "length": 2,    "output":3},
        "mm_8":     {"start": 688,                      "length": 2,    "output":3},
        "mm_9":     {"start": 689,                      "length": 2,    "output":3},
        "mm_10":    {"start": 690,                      "length": 2,    "output":3}
    }

    if kernel not in kernel_config:
        print(f"Error: Kernel '{kernel}' is not supported.")
        sys.exit(1)

    start = kernel_config[kernel]["start"]
    out_len = kernel_config[kernel]["length"]
    out_port = kernel_config[kernel]["output"]

    golden = binary_to_fp16(read_binary(DATA_PATH + kernel + "_output.txt"))
    result = binary_to_fp16(read_binary(OUTPUT_PATH + kernel + "_out2.txt"))
    # print(result)

    error = 0
    j = 0
    for i in range(start, start + out_len):
        if(result[i][out_port] != golden[j][0]):
            print(kernel, j, result[i][1], golden[j][0], "FAIL !!!")
            error = 1
        j += 1

    if(error == 0):
        print(f'{kernel} : PASS')
