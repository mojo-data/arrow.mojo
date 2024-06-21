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
    fn test_dtype[T: DType]() raises:
        var arrow_buf = ArrowFixedWidthVector(
            List[Scalar[T]](-11, 2, 4, 7643, 42)
        )
        assert_equal(len(arrow_buf), 5)
        assert_equal(arrow_buf.unsafe_get(0), -11)
        assert_equal(arrow_buf.unsafe_get(1), 2)
        assert_equal(arrow_buf.unsafe_get(2), 4)
        assert_equal(arrow_buf.unsafe_get(3), 7643)
        assert_equal(arrow_buf.unsafe_get(4), 42)
        assert_equal(arrow_buf.mem_used, 64)
        arrow_buf = ArrowFixedWidthVector[T](
            List[Optional[Scalar[T]]](
                Scalar[T](-11), None, Scalar[T](4), None, Scalar[T](42)
            )
        )
        assert_equal(len(arrow_buf), 5)
        assert_equal(arrow_buf[0].value(), -11)
        assert_false(arrow_buf[1])
        assert_equal(arrow_buf[2].value(), 4)
        assert_false(arrow_buf[3])
        assert_equal(arrow_buf[4].value(), 42)

    test_dtype[DType.int64]()
    test_dtype[DType.int32]()
    test_dtype[DType.int16]()
    test_dtype[DType.int8]()
    # negative numbers get implicitly casted to its uint equivalent
    test_dtype[DType.uint64]()
    test_dtype[DType.uint32]()
    test_dtype[DType.uint16]()
    test_dtype[DType.uint8]()
    test_dtype[DType.float64]()
    test_dtype[DType.float32]()
    test_dtype[DType.float16]()


def main():
    test_ArrowIntVector()
    test_ArrowFixedWidthVector_dtypes()
