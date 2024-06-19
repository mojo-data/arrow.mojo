from testing import assert_equal
from arrow.physical_layout.varlist import VariableSizedList


def test_var_list():
    var list_of_lists = List[List[Int64]](
        List[Int64](1, 2, 3),
        List[Int64](4, 5),
        List[Int64](),
        List[Int64](7, 8),
    )

    var var_list = VariableSizedList(list_of_lists)
    assert_equal(var_list[0][0], 1)
    assert_equal(var_list[0][1], 2)
    assert_equal(var_list[0][2], 3)
    assert_equal(var_list[1][0], 4)
    assert_equal(var_list[1][1], 5)
    assert_equal(len(var_list[2]), 0)
    assert_equal(var_list[3][0], 7)
    assert_equal(var_list[3][1], 8)


def main():
    test_var_list()
