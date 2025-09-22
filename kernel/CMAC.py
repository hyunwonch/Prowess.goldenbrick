import numpy as np
import math

def add(a_value, b_value):
        if (math.isinf(a_value) and math.isinf(b_value)) and (math.copysign(1.0, a_value) != math.copysign(1.0, b_value)):
            result = float('inf')
        else:
            result = a_value + b_value
        if math.isnan(result) or math.isinf(result):
            return float('inf') if math.copysign(1.0, result) == 1 else float('-inf')
        if result > (2 ** 16) or result < (-2 ** 16):
            return float('inf') if math.copysign(1.0, result) == 1 else float('-inf')
        if abs(result) < (2 ** -14):
                return -0.0 if math.copysign(1.0, result) == -1 else 0.0
        return result

def multiply(a_value, b_value):
    if math.isinf(a_value) or math.isinf(b_value) :
        if a_value == 0.0 or b_value == 0.0:
            result = float('inf')
        else:
            result = a_value * b_value
    else:
        result = a_value * b_value
    if math.isnan(result) or math.isinf(result):
        return float('inf') if math.copysign(1.0, result) == 1 else float('-inf')
    if result > (2 ** 16) or result < (-2 ** 16):
        return float('inf') if math.copysign(1.0, result) == 1 else float('-inf')
    if abs(result) < (2 ** -14):
            return -0.0 if math.copysign(1.0, result) == -1 else 0.0
    return result

def binary_to_fp16(binary_str):
        sign = int(binary_str[0], 2)
        exponent = int(binary_str[1:6], 2) # exponent treated as unsigned number, so should do e-bias
        mantissa = int(binary_str[6:], 2)

        if exponent == 0 and mantissa == 0:
            return 0.0 if sign == 0 else -0.0
        elif exponent == 31:
            if mantissa == 0:
                return float('inf') if sign == 0 else float('-inf')
            else:
                return float('inf') if sign == 0 else float('-inf')

        exponent = exponent - 15
        if exponent < -14:
            return +0.0 if sign == 0 else -0.0
        else:
            value = ((-1) ** sign) * ((mantissa / (2 ** 10)) + 1.0) * (2 ** exponent)

        return value

def fp16_to_binary(value):
    if np.isnan(value):
        return "0111111111111111"
    if np.isposinf(value):
        return "0111110000000000"
    if np.isneginf(value):
        return "1111110000000000"
    if value == 0.0:
        return "1000000000000000" if math.copysign(1.0, value) < 0 else "0000000000000000"

    sign = 0 if value > 0 else 1
    value = abs(value)

    exponent = np.floor(np.log2(value)) + 15
    exponent = min(max(exponent, 0), 31)
    mantissa = round((value / (2 ** (exponent - 15))) - 1.0, 10)
    mantissa_int = int(mantissa * (2 ** 10) + 0.5)

    if mantissa_int == 2 ** 10:
        exponent += 1
    exponent_bits = int(exponent) & 0b11111
    mantissa_bits = mantissa_int & 0b1111111111

    return f"{sign:01b}{exponent_bits:05b}{mantissa_bits:010b}"

def cmul(a,b,sub,real):
    a_bit = [fp16_to_binary(a[0]), fp16_to_binary(a[1])]
    b_bit = [fp16_to_binary(b[0]), fp16_to_binary(b[1])]
    br, bi = (-binary_to_fp16(b_bit[0]), -binary_to_fp16(b_bit[1])) if sub else (binary_to_fp16(b_bit[0]), binary_to_fp16(b_bit[1]))
    if real:
        # res = [np.float16(a[0])*br, np.float16(a[1])*bi]
        res = [multiply(binary_to_fp16(a_bit[0]),br), multiply(binary_to_fp16(a_bit[1]),bi)]
    else:
        # res = [np.float16(a[0])*br - np.float16(a[1])*bi, np.float16(a[0])*bi + np.float16(a[1])*br]
        arbr = multiply(binary_to_fp16(a_bit[0]),br)
        arbi = multiply(binary_to_fp16(a_bit[0]),bi)
        aibr = multiply(binary_to_fp16(a_bit[1]),br)
        aibi = multiply(binary_to_fp16(a_bit[1]),bi)

        arbr_bin = fp16_to_binary(arbr)
        arbi_bin = fp16_to_binary(arbi)
        aibr_bin = fp16_to_binary(aibr)
        neg_aibi_bin = fp16_to_binary(-aibi)
        arbr_value = binary_to_fp16(arbr_bin)
        arbi_value = binary_to_fp16(arbi_bin)
        aibr_value = binary_to_fp16(aibr_bin)
        neg_aibi_value = binary_to_fp16(neg_aibi_bin)

        res = [add(arbr_value, neg_aibi_value), add(arbi_value, aibr_value)]
        res = [binary_to_fp16(fp16_to_binary(res[0])), binary_to_fp16(fp16_to_binary(res[1]))]

    return res

def cadd(a,b,sub):
    a_bit = [fp16_to_binary(a[0]), fp16_to_binary(a[1])]
    b_bit = [fp16_to_binary(b[0]), fp16_to_binary(b[1])]
    br, bi = (-binary_to_fp16(b_bit[0]), -binary_to_fp16(b_bit[1])) if sub else (binary_to_fp16(b_bit[0]), binary_to_fp16(b_bit[1]))
    # br, bi = (-np.float16(b[0]), -np.float16(b[1])) if sub else (np.float16(b[0]), np.float16(b[1]))
    # res = [np.float16(a[0]) + br, np.float16(a[1]) + bi]
    res = [add(binary_to_fp16(a_bit[0]),br), add(binary_to_fp16(a_bit[1]),bi)]
    res = [binary_to_fp16(fp16_to_binary(res[0])), binary_to_fp16(fp16_to_binary(res[1]))]
    return res

def cdiv(a,b):
    res = [np.float16(a[0]) / np.float16(b[0]), np.float16(a[1]) / np.float16(b[1])]
    return res

def flt2int(a):
    """
    Convert a 16-bit IEEE754 float (np.float16) to signed 16-bit integer (int16)
    using round-to-nearest-even.
    """
    # Ensure input is float16
    fp16_val = binary_to_fp16(fp16_to_binary(a))
    
    # Round to nearest-even and cast to int16
    int16_val = np.int16(np.rint(fp16_val))
    
    return int16_val

def r_i_switch(a):

    z = [a[1],a[0]]

    return z

def conj(a):

    z = [a[0],-a[1]]

    return z