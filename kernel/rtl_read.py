import numpy as np
from pathlib import Path
from typing import List
from CMAC import binary_to_fp16

def read_rtl_file(file_path: Path) -> List[List[np.float16]]:
    """
    Read a single RTL output file and return all complex numbers
    as [real, imag] pairs.
    """
    complex_values: List[List[np.float16]] = []

    with file_path.open("r", encoding="utf-8") as f:
        for line_idx, raw_line in enumerate(f, start=1):
            words = raw_line.strip().split()
            for word_idx, word in enumerate(words, start=1):
                if len(word) != 32:
                    raise ValueError(
                        f"Line {line_idx}, word {word_idx}: "
                        f"expected 32 bits, got '{word}' (len={len(word)})"
                    )
                real_bits, imag_bits = word[:16], word[16:]
                if real_bits == 'x'*16:
                    real_bits = '1'*16
                if imag_bits == 'x'*16:
                    imag_bits = '1'*16
                # real_val = np.uint16(int(real_bits,2)).view(np.float16)
                # imag_val = np.uint16(int(imag_bits,2)).view(np.float16)
                real_val = binary_to_fp16(real_bits)
                imag_val = binary_to_fp16(imag_bits)
                complex_values.append([real_val, imag_val])

    return complex_values
