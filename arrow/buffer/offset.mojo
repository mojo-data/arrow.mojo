from arrow.util import ALIGNMENT, get_num_bytes_with_padding
from arrow.buffer.dtype import DTypeBuffer

alias OffsetBuffer32 = DTypeBuffer[DType.int32]
"""The offsets buffer contains length + 1 signed integers (32-bit),
which encode the start position of each slot in the data buffer. The length of
the value in each slot is computed using the difference between the offset at
that slot's index and the subsequent offset.
"""
alias OffsetBuffer64 = DTypeBuffer[DType.int64]
"""The offsets buffer contains length + 1 signed integers (64-bit), which
encode the start position of each slot in the data buffer. The length of the
value in each slot is computed using the difference between the offset at that
slot's index and the subsequent offset.
"""
