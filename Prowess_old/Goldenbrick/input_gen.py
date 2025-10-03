import random

# Function to generate random FP16 binary strings
def generate_random_fp16():
    sign = random.choice(['0', '1'])
    exponent = format(random.randint(0, 31), '05b')  # 5-bit exponent
    mantissa = format(random.randint(0, 1023), '010b')  # 10-bit mantissa
    return sign + exponent + mantissa

# Generate 1000 random FP16 input pairs
input_file = "../data/input.txt"
input_opa_file = "../data/input_opa.txt"
input_opb_file = "../data/input_opb.txt"

with open(input_file, "w") as file, open(input_opa_file, "w") as opa_file, open(input_opb_file, "w") as opb_file:
    for _ in range(2000):
        a = generate_random_fp16()
        b = generate_random_fp16()
        file.write(f"{a} {b}\n")
        opa_file.write(f"{a}\n")
        opb_file.write(f"{b}\n")

print(f"Random FP16 input pairs saved to {input_file}.")
print(f"Input A values saved to {input_opa_file}.")
print(f"Input B values saved to {input_opb_file}.")
