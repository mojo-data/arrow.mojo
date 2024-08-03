from arrow.util import ALIGNMENT, get_num_bytes_with_padding
from arrow.buffer.dtype import DTypeBuffer

alias OffsetBuffer32 = DTypeBuffer[Int32.element_type]
alias OffsetBuffer64 = DTypeBuffer[Int64.element_type]
