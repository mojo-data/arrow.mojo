from arrow import ArrowIntVector, ArrowFixedWidthVector
from testing import assert_equal, assert_almost_equal, assert_false


def test_ArrowIntVector():
    var int_arrow_buf = ArrowIntVector(List[Int](-11, 2, 4, 7643, 42))

    assert_equal(int_arrow_buf[0], -11)
    assert_equal(int_arrow_buf[1], 2)
    assert_equal(int_arrow_buf[2], 4)
    assert_equal(int_arrow_buf[3], 7643)
    assert_equal(int_arrow_buf[4], 42)

    assert_equal(len(int_arrow_buf), 5)
    assert_equal(int_arrow_buf.mem_used, 128)
    assert_equal(int_arrow_buf.value_buffer.mem_used, 64)


def test_ArrowFixedWidthVector_dtypes():
    fn test_int[T: DType]() raises:
        var int_arrow_buf = ArrowFixedWidthVector(
            List[Scalar[T]](-11, 2, 4, 7643, 42)
        )
        assert_equal(len(int_arrow_buf), 5)
        assert_equal(int_arrow_buf.unsafe_get(0), -11)
        assert_equal(int_arrow_buf.unsafe_get(1), 2)
        assert_equal(int_arrow_buf.unsafe_get(2), 4)
        assert_equal(int_arrow_buf.unsafe_get(3), 7643)
        assert_equal(int_arrow_buf.unsafe_get(4), 42)
        assert_equal(int_arrow_buf.mem_used, 64)
        int_arrow_buf = ArrowFixedWidthVector[T](
            List[Optional[Scalar[T]]](
                Scalar[T](-11), None, Scalar[T](4), None, Scalar[T](42)
            )
        )
        assert_equal(len(int_arrow_buf), 5)
        assert_equal(int_arrow_buf[0].value(), -11)
        assert_false(int_arrow_buf[1])
        assert_equal(int_arrow_buf[2].value(), 4)
        assert_false(int_arrow_buf[3])
        assert_equal(int_arrow_buf[4].value(), 42)

    test_int[DType.int64]()
    test_int[DType.int32]()
    test_int[DType.int16]()
    test_int[DType.int8]()
    test_int[DType.uint64]()
    test_int[DType.uint32]()
    test_int[DType.uint16]()
    test_int[DType.uint8]()

    fn test_float[T: DType]() raises:
        var float_arrow_buf = ArrowFixedWidthVector(
            List[Scalar[T]](-11, 2, 4, 7643, 42)
        )
        assert_equal(len(float_arrow_buf), 5)
        assert_equal(float_arrow_buf.unsafe_get(0), -11)
        assert_equal(float_arrow_buf.unsafe_get(1), 2)
        assert_equal(float_arrow_buf.unsafe_get(2), 4)
        assert_equal(float_arrow_buf.unsafe_get(3), 7643)
        assert_equal(float_arrow_buf.unsafe_get(4), 42)
        assert_equal(float_arrow_buf.mem_used, 64)
        float_arrow_buf = ArrowFixedWidthVector[T](
            List[Optional[Scalar[T]]](
                Scalar[T](-11), None, Scalar[T](4), None, Scalar[T](42)
            )
        )
        assert_equal(len(float_arrow_buf), 5)
        assert_equal(float_arrow_buf[0].value(), -11)
        assert_false(float_arrow_buf[1])
        assert_equal(float_arrow_buf[2].value(), 4)
        assert_false(float_arrow_buf[3])
        assert_equal(float_arrow_buf[4].value(), 42)

    test_float[DType.float64]()
    test_float[DType.float32]()
    test_float[DType.float16]()


def main():
    test_ArrowIntVector()
    test_ArrowFixedWidthVector_dtypes()
