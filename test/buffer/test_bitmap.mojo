from arrow import Bitmap
from testing import assert_equal


def check_if_works(bool_list: List[Bool]) -> Bitmap:
    var bitmap = Bitmap(bool_list)
    var list_from_bitmap = bitmap.to_list()

    for i in range(bool_list.size):
        assert_equal(bool_list[i], list_from_bitmap[i])

    return bitmap


def test_Bitmap_0():
    var test_case = List(False)
    var bitmap = check_if_works(test_case)
    assert_equal(bitmap.length, 1)
    assert_equal(bitmap.mem_used, 64)


def test_Bitmap_1():
    var test_case = List(True)
    var bitmap = check_if_works(test_case)
    assert_equal(bitmap.length, 1)
    assert_equal(bitmap.mem_used, 64)


def test_Bitmap_2():
    var test_case = List(False, False)
    var bitmap = check_if_works(test_case)
    assert_equal(bitmap.length, 2)
    assert_equal(bitmap.mem_used, 64)


def test_Bitmap_3():
    var test_case = List(False, True)
    var bitmap = check_if_works(test_case)
    assert_equal(bitmap.length, 2)
    assert_equal(bitmap.mem_used, 64)


def test_Bitmap_4():
    var test_case = List(True, False)
    var bitmap = check_if_works(test_case)
    assert_equal(bitmap.length, 2)
    assert_equal(bitmap.mem_used, 64)


def test_Bitmap_5():
    var test_case = List(False, True)
    var bitmap = check_if_works(test_case)
    assert_equal(bitmap.length, 2)
    assert_equal(bitmap.mem_used, 64)


def main():
    test_Bitmap_0()
    test_Bitmap_1()
    test_Bitmap_2()
    test_Bitmap_3()
    test_Bitmap_4()
    test_Bitmap_5()
