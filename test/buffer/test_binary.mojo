from testing import assert_true
from arrow.buffer.binary import BinaryBuffer


def list_equality(list1: List[UInt8], list2: List[UInt8]) -> Bool:
    if list1.size != list2.size:
        return False

    for i in range(list1.size):
        if list1[i] != list2[i]:
            return False

    return True


def test_BinaryBuffer():
    var test_case = List(UInt8(0), UInt8(1), UInt8(2), UInt8(3))
    var buffer = BinaryBuffer(test_case)
    var list_from_buffer = buffer.get_sequence(0, len(test_case))

    assert_true(list_equality(test_case, list_from_buffer))
    assert_true(buffer.length == len(test_case))
    assert_true(buffer.mem_used == 64)


def test_BinaryBuffer_2():
    var test_case = List(UInt8(0), UInt8(1), UInt8(31985))
    var buffer = BinaryBuffer(test_case)
    var list_from_buffer = buffer.get_sequence(0, len(test_case))

    assert_true(list_equality(test_case, list_from_buffer))
    assert_true(buffer.length == len(test_case))
    assert_true(buffer.mem_used == 64)
