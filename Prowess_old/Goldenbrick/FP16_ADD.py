import numpy as np
import math

class FP16AdderGoldenModel:
    def __init__(self, rounding_mode="nearest", ieee_mode="standard"):
        self.rounding_mode = rounding_mode
        self.ieee_mode = ieee_mode

    def binary_to_fp16(self, binary_str):
        sign = int(binary_str[0], 2)
        exponent = int(binary_str[1:6], 2) # exponent treated as unsigned number, so should do e-bias
        mantissa = int(binary_str[6:], 2)

        if exponent == 0 and mantissa == 0:
            return 0.0 if sign == 0 else -0.0
        elif exponent == 31:
            if mantissa == 0:
                return float('inf') if sign == 0 else float('-inf')
            else:
                if self.ieee_mode == "standard":
                    return float('nan')
                else:
                    return float('inf') if sign == 0 else float('-inf')

        exponent = exponent - 15
        if exponent < -14:
            if self.ieee_mode == "simplified":
                return +0.0 if sign == 0 else -0.0
            value = ((-1) ** sign) * (mantissa / (2 ** 10)) * (2 ** -14)
        else:
            value = ((-1) ** sign) * ((mantissa / (2 ** 10)) + 1.0) * (2 ** exponent)

        return value

    def fp16_to_binary(self, value):
        
        if np.isnan(value):
            return "0111111111111111"

        if np.isposinf(value):
            return "0111110000000000" # inf

        if np.isneginf(value):
            return "1111110000000000" # -inf

        if value == 0.0:
            return "1000000000000000" if math.copysign(1.0, value) == -1.0 else "0000000000000000"

        sign = 0 if value > 0 else 1
        value = abs(value)

        exponent = np.floor(np.log2(value)) + 15
        exponent = min(max(exponent, 0), 31)
        

        # mantissa = (value / (2 ** (exponent - 15))) - 1.0
        # mantissa_bits = int(mantissa * (2 ** 10)) & 0b1111111111

        mantissa = round((value / (2 ** (exponent - 15))) - 1.0, 10)
        # print(mantissa)
        mantissa_int = int(mantissa * (2 ** 10) + 0.5)
        # print(mantissa_int)
        if mantissa_int == 2 ** 10:
            exponent = exponent + 1 # Used to Update the exp since the mantissa may overflow under nearest rounding
        exponent_bits = int(exponent) & 0b11111
        mantissa_bits = mantissa_int & 0b1111111111
        # print(mantissa_bits)

        binary_str = f"{sign:01b}{exponent_bits:05b}{mantissa_bits:010b}"
        return binary_str

    def add(self, a_value, b_value):

        # Perform the actual addition
        if (math.isinf(a_value) and math.isinf(b_value)) and (math.copysign(1.0, a_value) != math.copysign(1.0, b_value)):
            result = float('inf')
        else:
            result = a_value + b_value

        # Manually handle overflow to the Maximum
        if math.isnan(result) or math.isinf(result):
            return float('inf') if math.copysign(1.0, result) == 1 else float('-inf')

        if result > (2 ** 16) or result < (-2 ** 16):
            return float('inf') if math.copysign(1.0, result) == 1 else float('-inf')

        if self.ieee_mode == "simplified":
            if abs(result) < (2 ** -14):
                return -0.0 if math.copysign(1.0, result) == -1 else 0.0

        return result

# Load inputs and calculate results
input_file = "../data/input.txt"
output_file = "../data/py_fpadd_output.txt"

adder = FP16AdderGoldenModel(rounding_mode="nearest", ieee_mode="simplified")

with open(input_file, "r") as infile, open(output_file, "w") as outfile:
    for line in infile:
        a_bin, b_bin = line.strip().split()
        a_value = adder.binary_to_fp16(a_bin)
        b_value = adder.binary_to_fp16(b_bin)
        result_dec = adder.add(a_value, b_value)
        result_bin = adder.fp16_to_binary(result_dec)
        outfile.write(result_bin + "\n")
    print("\033[32mAll results have been generated\033[0m")

# a_bin = "0000001111111111"
# b_bin = "0000001111111111"
# a_value = adder.binary_to_fp16(a_bin)
# print(a_value)
# b_value = adder.binary_to_fp16(b_bin)
# print(b_value)
# result_dec = adder.add(a_value, b_value)
# print(result_dec)
# result_bin = adder.fp16_to_binary(result_dec)
# print(result_bin)