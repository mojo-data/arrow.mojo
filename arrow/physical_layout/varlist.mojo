from arrow.util import ALIGNMENT, get_num_bytes_with_padding
from arrow.arrow import Bitmap
from arrow.buffer import DTypeBuffer, OffsetBuffer32, OffsetBuffer64


struct VariableSizedList[element_type: DType]:
    alias element_byte_width = sizeof[Self.element_type]()

    var length: Int
    var null_count: Int
    var validity: Bitmap
    var offsets: OffsetBuffer64
    var value_buffer: DTypeBuffer[element_type]

    var mem_used: Int

    fn __init__(
        inout self, values: List[List[Scalar[Self.element_type]]]
    ) raises:
        self.length = len(values)

        var validity_list = List[Bool](capacity=len(values))
        var offset_list = List[Int64](capacity=len(values) + 1)

        # Calculate the size of the buffer and allocate it
        var buffer_size = 0
        for i in range(len(values)):
            buffer_size += len(values[i])
        self.value_buffer = DTypeBuffer[element_type](buffer_size)

        offset_list.append(0)
        var offset_cursor: Int = 0
        for i in range(len(values)):
            # TODO: support nulls
            validity_list.append(True)
            var data_list = values[i]
            for value in data_list:
                self.value_buffer[offset_cursor] = value[]
                offset_cursor += 1
            offset_list.append(offset_cursor)

        self.null_count = 0
        self.validity = Bitmap(validity_list)
        self.offsets = OffsetBuffer64(offset_list)
        self.mem_used = self.value_buffer.mem_used + self.offsets.mem_used

    fn __getitem__(self, index: Int) raises -> List[Self.element_type]:
        if index < 0 or index >= self.length:
            # TODO: Sprintf the index into the error
            raise Error("index out of range for ArrowVariableSizedList")
        var ret = List[Self.element_type]()

        var start: Int = int(self.offsets[index])
        var length: Int = int(self.offsets[index + 1] - start)
        for i in range(length):
            ret.append(self.value_buffer[start + i])
        return ret

    fn __len__(self) -> Int:
        return self.length
