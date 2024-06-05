from arrow import ArrowFixedWidthBuffer


def test_ints():
    var ints = List[Int]()
    ints.append(-11)
    ints.append(2)
    ints.append(4)
    ints.append(7643)
    ints.append(-11)
    ints.append(2)
    ints.append(4)
    ints.append(7643)
    ints.append(-11)
    ints.append(2)
    ints.append(4)
    ints.append(7643)
    ints.append(-11)
    ints.append(2)
    ints.append(4)
    ints.append(7643)

    var int_arrow_buf = ArrowFixedWidthBuffer(ints)
    for i in range(int_arrow_buf.length):
        print(i, ": ", int_arrow_buf[i])
    print("mem use: ", int_arrow_buf.mem_use)
    print("bit_width: ", sizeof[Int]())


def main():
    test_ints()
