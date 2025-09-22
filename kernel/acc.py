import numpy as np
import random
from FPU import cmul, cadd
from utils import read_binary, binary_to_fp16, store_binary, generate_fp16

def acc(A):
    acc_real = A[0][0]
    acc_imag = A[0][1]
    for i in range(len(A)-1):
        real = A[i+1][0]
        imag = A[i+1][1]
        if type(real) is not np.float16 or type(imag) is not np.float16:
            print(type(real), type(imag))
            raise TypeError("Input must be a list of np.float16 pairs.")
        acc_real, acc_imag = cadd([acc_real, acc_imag], [real, imag])
        print(acc_real, acc_imag)
        # print(acc_real, acc_imag)
    return [acc_real, acc_imag]


if __name__ == "__main__":
    input_signal = generate_fp16(size=20, complex=True)
    store_binary(input_signal, '../PE/DATA/acc_input.txt')
    print(input_signal)
    accumulated_value = acc(input_signal)
    store_binary([accumulated_value], '../PE/DATA/acc_output.txt')
    print("Accumulated Value: ", accumulated_value)