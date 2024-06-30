from testing import assert_equal
from arrow.physical_layout.fixed_size_list import FixedSizedList


def test_fixed_size_list():
    var list_of_lists = List[List[Int64]](
        List[Int64](1, 2, 3),
        List[Int64](4, 5, 6),
        List[Int64](7, 8, 9),
    )

    var var_list = FixedSizedList(list_of_lists)
    assert_equal(var_list[0][0], 1)
    assert_equal(var_list[0][1], 2)
    assert_equal(var_list[0][2], 3)
    assert_equal(var_list[1][0], 4)
    assert_equal(var_list[1][1], 5)
    assert_equal(var_list[1][2], 6)
    assert_equal(var_list[2][0], 7)
    assert_equal(var_list[2][1], 8)
    assert_equal(var_list[2][2], 9)
