from .arrow import ArrowFixedWidthBuffer


def test_ints():
    var ints = DynamicVector[Int]()
    ints.push_back(-11)
    ints.push_back(2)
    ints.push_back(4)
    ints.push_back(7643)
    ints.push_back(-11)
    ints.push_back(2)
    ints.push_back(4)
    ints.push_back(7643)
    ints.push_back(-11)
    ints.push_back(2)
    ints.push_back(4)
    ints.push_back(7643)
    ints.push_back(-11)
    ints.push_back(2)
    ints.push_back(4)
    ints.push_back(7643)

    let int_arrow_buf = ArrowFixedWidthBuffer(ints)
    for i in range(int_arrow_buf.length):
        print(i, ": ", int_arrow_buf[i])
    print("mem use: ", int_arrow_buf.mem_use)
    print("bit_width: ", sizeof[Int]())


def main():
    test_ints()
