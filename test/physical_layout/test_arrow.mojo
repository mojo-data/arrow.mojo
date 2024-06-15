from arrow import ArrowIntVector
from testing import assert_equal


def test_ArrowIntVector():
    var ints = List[Int]()
    ints.append(-11)
    ints.append(2)
    ints.append(4)
    ints.append(7643)
    ints.append(69)

    var int_arrow_buf = ArrowIntVector(ints)

    assert_equal(int_arrow_buf[0], -11)
    assert_equal(int_arrow_buf[1], 2)
    assert_equal(int_arrow_buf[2], 4)
    assert_equal(int_arrow_buf[3], 7643)
    assert_equal(int_arrow_buf[4], 69)

    assert_equal(len(int_arrow_buf), 5)
    assert_equal(int_arrow_buf.mem_used, 128)
    assert_equal(int_arrow_buf.value_buffer.mem_used, 64)


def main():
    test_ArrowIntVector()
