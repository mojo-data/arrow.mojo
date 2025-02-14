from testing import assert_equal
from collections import Optional
from arrow.array.bool_array import ArrowBooleanArray


def test_ArrowBooleanArray():
    var bools = List[Optional[Bool]](True, None, False)
    var arr = ArrowBooleanArray(bools)
    for i in range(len(arr)):
        if arr[i] is None:
            print("None")
        else:
            print(arr[i].or_else(False))
    assert_equal(arr.length, 3)
    assert_equal(arr.null_count, 1)
    assert_equal(arr.mem_used, 128)
