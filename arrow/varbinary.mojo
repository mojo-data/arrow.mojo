from arrow.util import ALIGNMENT, get_num_bytes_with_padding
from arrow.arrow import Bitmap


struct ArrowStringVector:
    var length: Int
    var null_count: Int
    var validity: Bitmap
    var offsets: List[Int]
    var value_buffer: Pointer[UInt8]

    fn __init__(inout self, values: List[String]):
        var validity_list = List[Bool](capacity=len(values))
        var offset_list = List[Int](capacity=len(values) + 1)

        # Calculate the size of the buffer and allocate it
        var buffer_size = 0
        for i in range(len(values)):
            buffer_size += values[i]._buffer.size
        var num_bytes_with_padding = get_num_bytes_with_padding(buffer_size)
        self.value_buffer = Pointer[UInt8].alloc(
            num_bytes_with_padding, alignment=ALIGNMENT
        )

        offset_list.append(0)
        var offset_cursor = 0
        for i in range(len(values)):
            validity_list.append(True)
            var bytes = values[i].as_bytes()
            for j in range(len(bytes)):
                self.value_buffer.store(offset_cursor, bytes[j])
                offset_cursor += 1
            offset_list.append(offset_cursor)

        self.length = len(values)
        self.null_count = 0
        self.validity = Bitmap(validity_list)
        self.offsets = offset_list

    fn __getitem__(self, index: Int) raises -> String:
        if index < 0 or index >= self.length:
            raise Error("index out of range for ArrowStringVector")
        var start = self.offsets[index]
        var length = self.offsets[index + 1] - start

        var bytes = List[UInt8](length)
        for i in range(length):
            bytes.append(self.value_buffer.load(start + i))
        bytes.append(0)  # null-terminate the string
        return String(bytes)

    fn __len__(self) -> Int:
        return self.length

    fn __del__(owned self):
        self.value_buffer.free()
