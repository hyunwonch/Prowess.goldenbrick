def conv2d(input_image, kernel):
    """
    Perform 2D convolution between input_image and kernel.
    Uses dynamic zero-padding (out-of-bounds = 0).

    Args:
        input_image (list of list of float): 2D input image (HxW)
        kernel (list of list of float): 2D filter kernel (kh x kw)

    Returns:
        list of list of float: 2D convolution result
    """
    H = len(input_image)
    W = len(input_image[0])
    kh = len(kernel)
    kw = len(kernel[0])

    # Output image size (same as input with zero-padding logic)
    out_H = H
    out_W = W

    # Output matrix initialized with zeros
    output = [[0.0 for _ in range(out_W)] for _ in range(out_H)]

    # Calculate kernel center offset
    offset_h = kh // 2
    offset_w = kw // 2

    for i in range(out_H):
        for j in range(out_W):
            acc = 0.0
            for m in range(kh):
                for n in range(kw):
                    ii = i + m - offset_h
                    jj = j + n - offset_w
                    if 0 <= ii < H and 0 <= jj < W:
                        acc += kernel[m][n] * input_image[ii][jj]
                    else:
                        acc += kernel[m][n] * 0.0  # dynamic padding
            output[i][j] = acc

    return output


# Example usage
if __name__ == "__main__":
    H, W = 5, 5  # Input image size
    kh, kw = 3, 3  # Kernel size

    # Create example input image (5x5 ramp)
    input_image = [[float(i * W + j + 1) for j in range(W)] for i in range(H)]

    # Define simple 3x3 averaging kernel
    kernel = [[1/9.0 for _ in range(kw)] for _ in range(kh)]

    # Perform convolution
    output = conv2d(input_image, kernel)

    # Print input and result
    print("Input Image:")
    for row in input_image:
        print(row)

    print("\nKernel:")
    for row in kernel:
        print(row)

    print("\nConvolved Output:")
    for row in output:
        print(row)
