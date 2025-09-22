import numpy as np

def sat_int16(v: int) -> int:
    """Saturate to int16 range"""
    if v >  32767: return -32768
    if v < -32768: return 32767
    return v

def cordic(x: int, y: int, z: int, mode: int, flt: bool):
    ang_lut = [8192, 4836, 2555, 1297, 651, 325, 162, 81, 40, 20]
    pre_shift = False
    iterations = 10

    if (x >= -256 and x <= 255) and (y >= -256 and y <= 255):
        pre_shift = True
        x <<= 8
        y <<= 8

    # Quadrant correction
    if np.sign(y) >= 0 and np.sign(x) >= 0:
        pass
    elif np.sign(y) >= 0 and np.sign(x) < 0:
        xt, yt = y, -x
        x, y = xt, yt
    elif np.sign(y) < 0 and np.sign(x) >= 0:
        x, y = -x, -y
    else:
        xt, yt = -y, x
        x, y = xt, yt

    vector = (mode < 4)
    z_init = 0 if mode == 0 else z


    for i in range(iterations):
        if vector:
            di = 1 if y >= 0 else -1
            x_new = x + di * (y >> i)
            y_new = y - di * (x >> i)
            z_init += di * ang_lut[i]
        else:
            di = 1 if z >= 0 else -1
            x_new = x - di * (y >> i)
            y_new = y + di * (x >> i)
            z_init -= di * ang_lut[i]
        x, y = x_new, y_new

    # Final scaling

    x = (x * 0x4DBC) >> (23 if pre_shift else 15)
    y = (y * 0x4DBC) >> (23 if pre_shift else 15)

    x = sat_int16(x)
    y = sat_int16(y)

    if flt:
        if mode == 0:
            return [np.float16(x), np.float16(y)]
        elif mode == 1:
            return [np.float16(z_init), np.float16(0)]
        elif mode == 2:
            return [np.float16(x), np.float16(0)]
        elif mode == 3:
            return [np.float16(x), np.float16(z_init)]
        else:
            return [np.float16(x), np.float16(y)]
    else:
        if mode == 0:
            return [x, y]
        elif mode == 1:
            return [z_init, 0]
        elif mode == 2:
            return [x, 0]
        elif mode == 3:
            return [x, z_init]
        else:
            return [x, y]



if __name__ == "__main__":
    # x = 3
    # y = 4
    # z = 0

    # rs_x, rs_y, rs_z = cordic(x,y,z,0)
    # print(rs_x, rs_y, rs_z)

    # x = 3
    # y = -4
    # z = 0

    # rs_x, rs_y, rs_z = cordic(x,y,z,0)
    # print(rs_x, rs_y, rs_z)

    # x = -3
    # y = -4
    # z = 0

    # rs_x, rs_y, rs_z = cordic(x,y,z,0)
    # print(rs_x, rs_y, rs_z)

    # x = -4
    # y = 3
    # z = 0

    # rs_x, rs_y, rs_z = cordic(x,y,z,0)
    # print(rs_x, rs_y, rs_z)

    x = 0
    y = 2
    z = 0

    out = cordic(x,y,z,2)
    print(out)






