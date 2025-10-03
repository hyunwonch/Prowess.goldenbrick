# Custom PE Assembler

This assembler reads an assembly file (`test.txt`) describing one 84-bit instruction per line, encodes each line into a binary string, and writes the results to `output.bin`.

---

## Table of Contents

1. [File Format](#file-format)  
2. [Instruction Fields & Syntax](#instruction-fields--syntax)  
   - [Loop Control](#loop-control)  
   - [Input Crossbar](#input-crossbar)  
   - [Output Crossbar](#output-crossbar)  
   - [Clock Gating](#clock-gating)  
   - [DMEM Ports (1 & 2)](#dmem-ports-1--2)  
3. [Bit-Field Ordering](#bit-field-ordering)  
4. [Examples](#examples)  

---

## File Format

- **Input**: `test.txt`  
  - Plain text, UTF-8 encoding  
  - One instruction per non-blank, non-comment line  
  - Comment lines start with `#` and are ignored  

- **Output**: `output.bin`  
  - One 84-bit binary string per line (no conversion to integer/hex)  

---

## Instruction Fields & Syntax

All directives are comma-separated. Operands follow each mnemonic by a space.

### Loop Control

| Directive     | Meaning                                     |
|---------------|---------------------------------------------|
| `loop_start`  | Assert loop-start signal (1 bit = `1`)      |
| `loop_end`    | Assert loop-end   signal (1 bit = `1`)      |
| `loop_cnt N`  | 8-bit unsigned loop count (`0 ≤ N ≤ 255`)  |

### Input Crossbar

- **Syntax**: `input cb<start>-<end>`  
- **Bits**: 4-bit `start`, 4-bit `end`  
- **Range**: `0 ≤ start,end ≤ 15`  

### Output Crossbar

- **Syntax**: `output cb<start>-<end>`  
- **Bits**: 4-bit `start`, 2-bit `end`  
- **Ranges**:  
  - `0 ≤ start ≤ 15`  
  - `0 ≤ end   ≤  3`  

### Clock Gating

| Directive | Meaning                                      |
|-----------|----------------------------------------------|
| `cg1`     | Enable gating signal 1 (1 bit = `1`)         |
| `cg2`     | Enable gating signal 2 (1 bit = `1`)         |

### DMEM Ports (1 & 2)

Two symmetric DMEM ports share a single bank selection bit each (`bank_sel1`/`bank_sel2`). For each port:

1. **Bank select**  
   - `bank_sel<port> B`  
   - 1-bit (`B ∈ {0,1}`)  

2. **Write side**  
   - `valid_w<port> V` (`V ∈ {0,1}`)  
     - If `V = 1`:  
       - `waddr<port> A`  
       - 9-bit address (`0 ≤ A ≤ 511`)  
     - If `V = 0`:  
       - `wmode<port> M`  
       - 2-bit mode in **LSBs**, MSBs zero:  
         - `idle` = `00`  
         - `incr` = `01`  
         - `dec`  = `10`  
         - `stay` = `11`  

3. **Read side**  
   - `valid_r<port> V` (`V ∈ {0,1}`)  
     - If `V = 1`:  
       - `raddr<port> A`  
       - 9-bit address (`0 ≤ A ≤ 511`)  
     - If `V = 0`:  
       - `rmode<port> M`  
       - 2-bit mode in **LSBs**, MSBs zero (same encoding as write modes)  

> **Note:** replace `<port>` with `1` or `2`, e.g. `valid_w1`, `rmode2`, etc.

---

## Bit-Field Ordering

When concatenated (MSB → LSB), the 84 bits appear in this sequence:

1. **Loop**  
   - `loop_start` (1 bit)  
   - `loop_end`   (1 bit)  
   - `loop_cnt`   (8 bits)  

2. **Crossbar**  
   - `input_cb`: start (4) + end (4)  
   - `output_cb`: start (4) + end (2)  

3. **Clock Gating**  
   - `cg1` (1)  
   - `cg2` (1)  

4. **DMEM Port 1**  
   - `bank_sel1` (1)  
   - `valid_w1`  (1) + [`waddr1` (9) **or** `wmode1` (2 LSB) + 7 zeros]  
   - `valid_r1`  (1) + [`raddr1` (9) **or** `rmode1` (2 LSB) + 7 zeros]  

5. **DMEM Port 2**  
   - `bank_sel2` (1)  
   - `valid_w2`  (1) + [`waddr2` or `wmode2`]  
   - `valid_r2`  (1) + [`raddr2` or `rmode2`]  

6. **Padding**  
   - Zeros until total length = 84 bits  

---

## Examples

```asm
# 1) Simple loop + crossbar
loop_start, loop_cnt 16, input cb2-7, output cb5-1, cg1, cg2
loop_end

# 2) DMEM1 write by address, DMEM2 read by mode
bank_sel1 1, valid_w1 1, waddr1 300, \
bank_sel2 0, valid_r2 0, rmode2 dec

# 3) Full example all fields
loop_start, loop_cnt 4, input cb0-3, output cb7-2, cg1, \
bank_sel1 1, valid_w1 0, wmode1 incr, valid_r1 1, raddr1 123, \
bank_sel2 0, valid_w2 1, waddr2 45, valid_r2 0, rmode2 stay
loop_end
