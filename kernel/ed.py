import numpy as np
import random
from FPU import cmul, cadd
# from utils import generate_fp16, conj, store_binary
from utils import conj, read_binary, binary_to_fp16, store_binary, generate_fp16, fp16_to_binary, int_to_binary, binary_to_int

# def read_binary(filename):
#     with open(filename, 'r') as file:
#         lines = file.readlines()

#     parsed_lines = []

#     for line in lines:
#         line = line.strip().replace(" ", "")
#         n_bits = len(line)

#         if n_bits % 32 != 0:
#             raise ValueError(f"Invalid bit length in line: {line} (not a multiple of 32)")

#         n_complex = n_bits // 32
#         complex_vals = []

#         for i in range(n_complex):
#             # 32bit chunk: [real|imag]
#             chunk = line[i*32 : (i+1)*32]
#             real_bin = chunk[0:16]
#             imag_bin = chunk[16:32]
#             complex_vals.append([real_bin, imag_bin])

#         if n_complex == 1:
#             parsed_lines.append([real_bin, imag_bin])
#         else:
#             parsed_lines.append(complex_vals)

#     return parsed_lines

# def binary_to_fp16(binary_array):
#     float16_array = []

#     # print(len(binary_array), "complex numbers found in the file.")
#     for line in binary_array:
#         complex_line = []
#         # print(len(line[0]))
#         if(len(line[0]) == 16):
#             # Single complex number case
#             real_fp16 = np.uint16(int(line[0], 2)).view(np.float16)
#             imag_fp16 = np.uint16(int(line[1], 2)).view(np.float16)
#             complex_line.append([real_fp16, imag_fp16])
#         else:
#             for real, imag in line:
#                 if(real == "xxxxxxxxxxxxxxxx"):
#                     real = "1" * 16
#                 if(imag == "xxxxxxxxxxxxxxxx"):
#                     imag = "1" * 16
#                 real_fp16 = np.uint16(int(real, 2)).view(np.float16)
#                 imag_fp16 = np.uint16(int(imag, 2)).view(np.float16)
#                 complex_line.append([real_fp16, imag_fp16])
#         float16_array.append(complex_line)

#     return float16_array


def ed(A):
    acc = [np.float16(0.0), np.float16(0.0)]
    acc_list = []
    for i in range(len(A)):
        # print(A[i], conj(A[i]))
        tmp = cmul(A[i], conj(A[i]))
        acc = cadd(acc, tmp)
        acc_list.append(acc)
        # print(acc)
    return acc, acc_list


if __name__ == "__main__":

    input_signal = generate_fp16(size=128, complex=True)
    store_binary(input_signal, '/net/badwater/z/hyunwon/Documents/_GIT/PROWESS/SIM/PE/DATA/ed_input.txt')
    # print(input_signal)

    ed_value, acc_list = ed(input_signal)
    print("Accumulated Value: ", ed_value)
    print(fp16_to_binary(ed_value[0]))
    print(int_to_binary(20417), binary_to_fp16(int_to_binary(20417)))
    store_binary([ed_value], '/net/badwater/z/hyunwon/Documents/_GIT/PROWESS/SIM/PE/DATA/ed_output.txt')
    store_binary(acc_list, '/net/badwater/z/hyunwon/Documents/_GIT/PROWESS/SIM/PE/DATA/ed_acc.txt')
