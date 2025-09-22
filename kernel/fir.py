def fir(input_signal, coefficients):
    """
    Applies an FIR filter to the input_signal using the provided coefficients.

    Args:
        input_signal (list of float): The signal to be filtered.
        coefficients (list of float): FIR filter coefficients (taps).

    Returns:
        list of float: The filtered output signal.
    """
    n_taps = len(coefficients)
    n_samples = len(input_signal)

    # Zero-padding the input signal at the beginning
    padded_signal = [0.0] * (n_taps - 1) + input_signal
    print("Padded Signal : ", padded_signal)
    output_signal = []

    for i in range(n_samples):
        acc = 0.0
        for j in range(n_taps):
            acc += coefficients[j] * padded_signal[i + j]
        output_signal.append(acc)

    return output_signal


if __name__ == "__main__":

    number_of_taps = 8
    input_length = 20

    # Generate example FIR filter coefficients (e.g., simple averaging)
    fir_coeffs = [1.0 / number_of_taps] * number_of_taps

    # Generate example input signal (e.g., ramp signal)
    input_signal = [float(i) for i in range(1, input_length + 1)]

    # Perform filtering
    output = fir(input_signal, fir_coeffs)

    # Print result
    print("Input Signal:   ", input_signal)
    print("FIR Coeffs:     ", fir_coeffs)
    print("Filtered Output:", output)
