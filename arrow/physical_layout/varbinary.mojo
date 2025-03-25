from arrow.util import ALIGNMENT, get_num_bytes_with_padding
from arrow.arrow import Bitmap
from arrow.buffer import BinaryBuffer, OffsetBuffer32, OffsetBuffer64


struct ArrowStringVector:
    var length: Int
    var null_count: Int
    var validity: Bitmap
    var offsets: OffsetBuffer32
    var value_buffer: BinaryBuffer
    var mem_used: Int

    fn __init__(mut self, values: List[String]):
        var validity_list = List[Bool](capacity=len(values))
        var offset_list = List[Int32](capacity=len(values) + 1)

        # Calculate the size of the buffer and allocate it
        var buffer_size = 0
        for i in range(len(values)):
            buffer_size += len(values[i]._buffer)
        self.value_buffer = BinaryBuffer(buffer_size)

        offset_list.append(0)
        var offset_cursor = 0
        for i in range(len(values)):
            validity_list.append(True)
            var bytes = values[i].as_bytes()
            self.value_buffer._unsafe_set_sequence(offset_cursor, List(bytes))
            offset_cursor += len(bytes)
            offset_list.append(offset_cursor)

        self.length = len(values)
        self.null_count = 0
        self.validity = Bitmap(validity_list)
        self.offsets = OffsetBuffer32(offset_list)
        self.mem_used = self.value_buffer.mem_used + self.offsets.mem_used

    fn __getitem__(self, index: Int) raises -> String:
        if index < 0 or index >= self.length:
            raise Error("index out of range for ArrowStringVector")
        var start = self.offsets[index]
        var length = self.offsets[index + 1] - start

        var bytes = self.value_buffer._unsafe_get_sequence(
            Int(start), Int(length)
        )

        bytes.extend(List[UInt8](0))
        var ret = String(buffer=bytes)
        return ret

    fn __setitem__(self, index: Int, value: String) raises:
        if index < 0 or index >= self.length:
            raise Error("index out of range for ArrowStringVector")
        var bytes = value.as_bytes()
        self.value_buffer.set_sequence(Int(self.offsets[index]), List(bytes))

    fn __len__(self) -> Int:
        return self.length
