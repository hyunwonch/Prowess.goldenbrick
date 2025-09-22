def matvec_multiply(matrix, vector):
    """
    Perform matrix-vector multiplication: y = A × x

    Args:
        matrix (list of list of float): Matrix A of size M x N
        vector (list of float): Vector x of size N

    Returns:
        list of float: Resulting vector y of size M
    """
    M = len(matrix)
    N = len(matrix[0])

    if len(vector) != N:
        raise ValueError("Vector size does not match matrix column count.")

    result = [0.0 for _ in range(M)]

    for i in range(M):
        for j in range(N):
            result[i] += matrix[i][j] * vector[j]

    return result


# Example usage
if __name__ == "__main__":
    M = 4  # Rows in matrix A
    N = 3  # Columns in matrix A, and length of vector x

    # Example matrix A (M x N)
    A = [[float(i * N + j + 1) for j in range(N)] for i in range(M)]

    # Example vector x (length N)
    x = [float(j + 1) for j in range(N)]

    # Perform multiplication
    y = matvec_multiply(A, x)

    # Print inputs and result
    print("Matrix A:")
    for row in A:
        print(row)

    print("\nVector x:")
    print(x)

    print("\nResult y = A × x:")
    print(y)
