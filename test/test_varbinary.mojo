from testing import assert_equal
from arrow.varbinary import ArrowStringVector

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

    var string_arrow_buf = ArrowStringVector(strings)
    assert_equal(string_arrow_buf[0], "hello")
    assert_equal(string_arrow_buf[1], "world")
    assert_equal(string_arrow_buf[2], "this")
    assert_equal(string_arrow_buf[3], "is")
    assert_equal(string_arrow_buf[4], "a")
    assert_equal(string_arrow_buf[5], "test")
    assert_equal(string_arrow_buf[6], "of")
    assert_equal(string_arrow_buf[7], "strings")

    #assert_equal(len(string_arrow_buf), 8)
    #assert_equal(string_arrow_buf.mem_use, 64)