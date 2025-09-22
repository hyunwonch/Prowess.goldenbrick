def cmul(A, B):
    """
    Perform complex multiply-accumulate operation on two complex numbers A and B.
    A and B are represented as tuples of (real, imag).
    """
    a_real, a_imag = A
    b_real, b_imag = B

    # Complex Multiply (a+bi) * (c+di) = (ac-bd)+(ad+bc)i
    arbr = a_real * b_real
    arbi = a_real * b_imag
    aibr = a_imag * b_real
    aibi = a_imag * b_imag

    mout_r = arbr - aibi
    mout_i = arbi + aibr

    return [mout_r, mout_i]


def cadd(A, B):
    """
    Perform complex addition on two complex numbers A and B.
    A and B are represented as tuples of (real, imag).
    """
    a_real, a_imag = A
    b_real, b_imag = B

    # Complex Addition (a+bi) + (c+di) = (a+c)+(b+d)i
    mout_r = a_real + b_real
    mout_i = a_imag + b_imag

    return [mout_r, mout_i]