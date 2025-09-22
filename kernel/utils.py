import numpy as np
import random
import math

def binary_to_integer(binary_str: str, bit_width: int = 16, signed: bool = True) -> int:
    """
    Convert a binary string to integer with configurable bit width.

    Args:
        binary_str (str): Input binary string (e.g., "1101").
        bit_width (int): Bit width of the number.
        signed (bool): If True, interpret as signed integer (two's complement).
                       If False, interpret as unsigned integer.

    Returns:
        int: Converted integer value.
    """
    # Ensure binary string fits the bit width
    if len(binary_str) > bit_width:
        raise ValueError(f"Input binary string longer than bit_width ({bit_width})")

    # Zero-pad if necessary
    binary_str = binary_str.zfill(bit_width)

    # Unsigned value
    value = int(binary_str, 2)

    # Handle signed (two's complement)
    if signed:
        sign_bit = 1 << (bit_width - 1)
        if value & sign_bit:  # If sign bit is set
            value -= (1 << bit_width)

    return value

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

# def read_binary(filename):
#     with open(filename, 'r') as file:
#         lines = file.readlines()
#     lines = [line.strip() for line in lines]

#     if len(lines[0].split()) == 2:
#         for i in range(len(lines)):
#             real = lines[i].split()[0]
#             imag = lines[i].split()[1]
#             lines[i] = [real, imag]
#     return lines

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

# def store_binary(data, filename='input.txt'):
#     with open(filename, 'w') as file:
#         if isinstance(data[0], (list, tuple)) and len(data[0]) == 2:
#             for real, imag in data:
#                 # real_bits = real.view(np.uint16)
#                 # imag_bits = imag.view(np.uint16)
#                 real_bits = fp16_to_binary(real)
#                 imag_bits = fp16_to_binary(imag)
#                 file.write(f"{real_bits}{imag_bits}\n")
#         else:
#             for val in data:
#                 val_bits = val.view(np.uint16)
#                 file.write(f"{val_bits:016b}\n")

def store_binary(data, filename='input.txt', zero_padding=0):
    with open(filename, 'w') as file:
        # First, write zero_padding lines of zeros
        if isinstance(data[0], (list, tuple)) and len(data[0]) == 2:
            # Complex numbers case
            for _ in range(zero_padding):
                file.write(f"{'0' * 32}\n")  # 16 bits real + 16 bits imag = 32 bits
            for real, imag in data:
                real_bits = fp16_to_binary(real)
                imag_bits = fp16_to_binary(imag)
                file.write(f"{real_bits}{imag_bits}\n")
        else:
            # Single values case
            for _ in range(zero_padding):
                file.write(f"{'0' * 16}\n")  # 16 bits total
            for val in data:
                val_bits = val.view(np.uint16)
                file.write(f"{val_bits:016b}\n")

def store_binary_1(data, filename='input.txt', zero_padding=0, mid_zeros=None):

    if mid_zeros is None:
        mid_zeros_map = {}
    elif isinstance(mid_zeros, dict):
        mid_zeros_map = dict(mid_zeros)
    else:
        mid_zeros_map = {}
        for idx, cnt in mid_zeros:
            mid_zeros_map[idx] = mid_zeros_map.get(idx, 0) + cnt

    def write_zeros(f, lines, width_bits):
        if lines <= 0:
            return
        line = '0' * width_bits
        for _ in range(lines):
            f.write(f"{line}\n")

    with open(filename, 'w') as file:
        is_complex_pair = isinstance(data[0], (list, tuple)) and len(data[0]) == 2
        width_bits = 32 if is_complex_pair else 16

        write_zeros(file, zero_padding, width_bits)
        if is_complex_pair:
            for idx, (real, imag) in enumerate(data):
                write_zeros(file, mid_zeros_map.get(idx, 0), width_bits)
                real_bits = fp16_to_binary(real)
                imag_bits = fp16_to_binary(imag)
                file.write(f"{real_bits}{imag_bits}\n")
        else:
            for idx, val in enumerate(data):
                write_zeros(file, mid_zeros_map.get(idx, 0), width_bits)
                val_bits = val.view(np.uint16)  
                file.write(f"{val_bits:016b}\n")


def generate_fp16(size=10, complex=False, seed=42):
    random.seed(seed)
    data = []
    for _ in range(size):
        if(complex):
            real = np.float16(random.uniform(-1, 2))
            imag = np.float16(random.uniform(-1, 2))
            data.append([real, imag])
        else:
            data.append(np.float16(random.uniform(-100, 100)))
    return data

def conj(z):
    """
    Compute the conjugate of a complex number represented in FP16.
    Input: z = [real, imag] where both are np.float16
    Output: [real, -imag] with dtype=np.float16
    """
    if not isinstance(z, (list, tuple)) or len(z) != 2:
        raise ValueError("Input must be a list or tuple with two elements [real, imag].")

    real = np.float16(z[0])
    imag = np.float16(z[1])

    return [real, np.float16(-imag)]


def int_to_binary(value: int, bit_width: int = 16, signed: bool = True) -> str:
    """
    Convert integer to binary string with configurable bit width.

    Args:
        value (int): Integer value to convert.
        bit_width (int): Bit width of the binary representation.
        signed (bool): If True, treat value as signed two's complement.

    Returns:
        str: Binary string of length bit_width.
    """
    if signed:
        # Range check for signed
        min_val = -(1 << (bit_width - 1))
        max_val = (1 << (bit_width - 1)) - 1
        if not (min_val <= value <= max_val):
            raise ValueError(f"Value {value} out of range for {bit_width}-bit signed integer")
        if value < 0:
            value = (1 << bit_width) + value  # two's complement
    else:
        # Range check for unsigned
        min_val = 0
        max_val = (1 << bit_width) - 1
        if not (min_val <= value <= max_val):
            raise ValueError(f"Value {value} out of range for {bit_width}-bit unsigned integer")

    return f"{value:0{bit_width}b}"


def binary_to_int(binary_str: str, bit_width: int = 16, signed: bool = True) -> int:
    """
    Convert binary string to integer with configurable bit width.

    Args:
        binary_str (str): Input binary string (e.g., "1101").
        bit_width (int): Bit width of the number.
        signed (bool): If True, interpret as signed two's complement.

    Returns:
        int: Converted integer value.
    """
    if len(binary_str) > bit_width:
        raise ValueError(f"Binary string longer than bit_width ({bit_width})")

    # Zero-pad to bit_width
    binary_str = binary_str.zfill(bit_width)

    # Unsigned interpretation
    value = int(binary_str, 2)

    if signed:
        sign_bit = 1 << (bit_width - 1)
        if value & sign_bit:  # sign bit set
            value -= (1 << bit_width)

    return value
