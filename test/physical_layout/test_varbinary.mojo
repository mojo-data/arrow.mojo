from testing import assert_equal
from arrow.physical_layout.varbinary import ArrowStringVector


def test_string_vector():
    var strings = List[String]()
    strings.append("hello")
    strings.append("world")
    strings.append("this")
    strings.append("is")
    strings.append("a")
    strings.append("test")
    strings.append("of")
    strings.append("strings")

    var string_vec = ArrowStringVector(strings)

    assert_equal(string_vec[0], "hello")
    assert_equal(string_vec[1], "world")
    assert_equal(string_vec[2], "this")
    assert_equal(string_vec[3], "is")
    assert_equal(string_vec[4], "a")
    assert_equal(string_vec[5], "test")
    assert_equal(string_vec[6], "of")
    assert_equal(string_vec[7], "strings")


def main():
    test_string_vector()
