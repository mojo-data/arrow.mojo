from arrow.util import ALIGNMENT, get_num_bytes_with_padding
from arrow.arrow import Bitmap
from arrow.buffer import DTypeBuffer, OffsetBuffer32, OffsetBuffer64


struct VariableSizedList[type: DType]:
    alias _ptr_type = DTypePointer[type]
    alias element_type = Scalar[type]
    alias element_byte_width = sizeof[Self.element_type]()
    
    var length: Int
    var null_count: Int
    var validity: Bitmap
    var offsets: OffsetBuffer64
    var value_buffer: DTypeBuffer[type]
    var _buffer: Self._ptr_type

    var mem_used: Int

    fn __init__(inout self, values: List[List[DType]]) raises:
        self.length = len(values)
    

        var validity_list = List[Bool](capacity=len(values))
        var offset_list = List[Int](capacity=len(values) + 1)

        # Calculate the size of the buffer and allocate it
        var buffer_size = 0
        for i in range(len(values)):
            buffer_size += len(values[i])
        self.value_buffer = DTypeBuffer[type](buffer_size)

        offset_list.append(0)
        var offset_cursor = 0
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

    fn __getitem__(self, index: Int) raises -> DType:
        if index < 0 or index >= self.length:
            # TODO: Sprintf the index into the error
            raise Error("index out of range for ArrowVariableSizedList")
    #     var start = self.offsets[index]
    #     var length = self.offsets[index + 1] - start

    #     var bytes = self.value_buffer._unsafe_get_sequence(
    #         rebind[Int](start), rebind[Int](length)
    #     )
    #     bytes.extend(
    #         List(UInt8(0))
    #     )  # TODO: null terminate string without copying
    #     return String(bytes)

    fn __len__(self) -> Int:
        return self.length
