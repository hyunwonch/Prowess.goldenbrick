import numpy as np

def autocorr(A):
    """
    Compute the autocorrelation function of a vector A.
    A: 1D array or 2D array with shape (N,1) or (1,N).
    Returns an array x of length N containing the autocorrelation,
    normalized by the zero-lag value.
    """
    A = np.asarray(A)

    # If A is a 2D array, ensure it is either a row or column vector
    if A.ndim > 2 or (A.ndim == 2 and not (1 in A.shape)):
        raise ValueError("Input must be a vector, not a matrix!")

    # Flatten any 2D row/column vector into 1D
    if A.ndim == 2:
        A = A.flatten()

    N = A.size
    x = np.zeros(N, dtype=np.float64)

    # Compute zero-lag autocorrelation (sum of squares)
    x[0] = np.dot(A, A)

    # Compute autocorrelation for each lag from 1 to N-1
    for lag in range(1, N):
        # Equivalent to MATLAB's circshift(A, -lag) then taking first N-lag samples
        # Here we align A[lag:] with A[:N-lag] and take dot product
        x[lag] = np.dot(A[lag:], A[:N - lag])

    # Normalize by the zero-lag value if it is nonzero
    if x[0] != 0:
        x = x / x[0]

    return x
