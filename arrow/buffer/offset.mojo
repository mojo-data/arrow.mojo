from arrow.util import ALIGNMENT, get_num_bytes_with_padding
from arrow.buffer.dtype import DTypeBuffer

alias OffsetBuffer32 = DTypeBuffer[DType.int32]
alias OffsetBuffer64 = DTypeBuffer[DType.int64]
