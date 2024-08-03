"""
Arrow buffers are recommended to have an alignment and padding of 64 bytes

https://arrow.apache.org/docs/format/Columnar.html#buffer-alignment-and-padding.
"""
import math

alias PADDING = 64
alias ALIGNMENT = 64


fn get_num_bytes_with_padding(num_bytes_before_padding: Int) -> Int:
    return math.align_up(num_bytes_before_padding, PADDING)
