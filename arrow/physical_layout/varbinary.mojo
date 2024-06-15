from arrow.util import ALIGNMENT, get_num_bytes_with_padding
from arrow.arrow import Bitmap
from arrow.buffer import BinaryBuffer, OffsetBuffer


struct ArrowStringVector:
    var length: Int
    var null_count: Int
    var validity: Bitmap
    var offsets: OffsetBuffer
    var value_buffer: BinaryBuffer
    var mem_used: Int

    fn __init__(inout self, values: List[String]):
        var validity_list = List[Bool](capacity=len(values))
        var offset_list = List[Int](capacity=len(values) + 1)

        # Calculate the size of the buffer and allocate it
        var buffer_size = 0
        for i in range(len(values)):
            buffer_size += values[i]._buffer.size
        self.value_buffer = BinaryBuffer(buffer_size)

        offset_list.append(0)
        var offset_cursor = 0
        for i in range(len(values)):
            validity_list.append(True)
            var bytes = values[i].as_bytes()
            self.value_buffer._unsafe_set_sequence(offset_cursor, bytes)
            offset_cursor += len(bytes)
            offset_list.append(offset_cursor)

        self.length = len(values)
        self.null_count = 0
        self.validity = Bitmap(validity_list)
        self.offsets = OffsetBuffer(offset_list)
        self.mem_used = self.value_buffer.mem_used + self.offsets.mem_used

    fn __getitem__(self, index: Int) raises -> String:
        if index < 0 or index >= self.length:
            raise Error("index out of range for ArrowStringVector")
        var start = self.offsets[index]
        var length = self.offsets[index + 1] - start

        var bytes = self.value_buffer._unsafe_get_sequence(start, length)
        bytes.extend(
            List(UInt8(0))
        )  # TODO: null terminate string without copying
        return String(bytes)

    fn __len__(self) -> Int:
        return self.length
