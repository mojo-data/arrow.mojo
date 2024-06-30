from arrow.util import get_num_bytes_with_padding
from testing import assert_true


def test_get_num_bytes_with_padding():
    assert_true(get_num_bytes_with_padding(0) == 0)
    assert_true(get_num_bytes_with_padding(1) == 64)
    assert_true(get_num_bytes_with_padding(63) == 64)
    assert_true(get_num_bytes_with_padding(64) == 64)
    assert_true(get_num_bytes_with_padding(65) == 128)
    assert_true(get_num_bytes_with_padding(127) == 128)
    assert_true(get_num_bytes_with_padding(128) == 128)
    assert_true(get_num_bytes_with_padding(129) == 192)
    assert_true(get_num_bytes_with_padding(191) == 192)
    assert_true(get_num_bytes_with_padding(192) == 192)
    assert_true(get_num_bytes_with_padding(193) == 256)
    assert_true(get_num_bytes_with_padding(255) == 256)
    assert_true(get_num_bytes_with_padding(256) == 256)
    assert_true(get_num_bytes_with_padding(257) == 320)
