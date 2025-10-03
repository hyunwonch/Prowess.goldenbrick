import random

# Function to generate random FP16 binary strings
def generate_random_fp16():
    sign = random.choice(['0', '1'])
    exponent = format(random.randint(0, 31), '05b')  # 5-bit exponent
    mantissa = format(random.randint(0, 1023), '010b')  # 10-bit mantissa
    return sign + exponent + mantissa

# Function to generate a 32-bit number from two FP16 values
def generate_random_fp32():
    fp16_a = generate_random_fp16()
    fp16_b = generate_random_fp16()
    return fp16_a + fp16_b

# Generate 2000 random 32-bit input sets
input_file = "../data/cmac_input.txt"
input_opa_file = "../data/cmac_opa.txt"
input_opb_file = "../data/cmac_opb.txt"
input_opc_file = "../data/cmac_opc.txt"
input_opd_file = "../data/cmac_opd.txt"

with open(input_file, "w") as file, open(input_opa_file, "w") as opa_file, open(input_opb_file, "w") as opb_file, open(input_opc_file, "w") as opc_file, open(input_opd_file, "w") as opd_file:
    for _ in range(2000):
        a = generate_random_fp32()
        b = generate_random_fp32()
        c = generate_random_fp32()
        d = generate_random_fp32()

        file.write(f"{a} {b} {c} {d}\n")
        opa_file.write(f"{a}\n")
        opb_file.write(f"{b}\n")
        opc_file.write(f"{c}\n")
        opd_file.write(f"{d}\n")

print(f"Random 32-bit FP16 input pairs saved to {input_file}.")
print(f"Input A values saved to {input_opa_file}.")
print(f"Input B values saved to {input_opb_file}.")
print(f"Input C values saved to {input_opc_file}.")
print(f"Input D values saved to {input_opd_file}.")
