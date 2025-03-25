from arrow.util import ALIGNMENT, get_num_bytes_with_padding
from arrow.arrow import Bitmap
from arrow.buffer import DTypeBuffer, OffsetBuffer32, OffsetBuffer64


struct FixedSizedList[element_type: DType]:
    alias element_byte_width = sizeof[Self.element_type]()

    var length: Int
    var null_count: Int
    var validity: Bitmap
    var value_buffer: DTypeBuffer[element_type]
    var list_size: Int

    var mem_used: Int

    fn __init__(mut self, values: List[List[Scalar[Self.element_type]]]) raises:
        self.length = len(values)
        self.list_size = len(values[0])
        self.value_buffer = DTypeBuffer[element_type](
            self.list_size * len(values)
        )

        var validity_list = List[Bool](capacity=len(values))
        var offset_list = List[Int](capacity=len(values) + 1)

        offset_list.append(0)
        var offset_cursor: Int = 0
        for i in range(len(values)):
            # TODO: support nulls
            if len(values[i]) != self.list_size:
                raise Error(
                    "FixedSizedList: list size mismatch on index: " + String(i)
                )
            validity_list.append(True)
            for j in range(self.list_size):
                self.value_buffer[offset_cursor] = values[i][j]
                offset_cursor += 1
            offset_list.append(offset_cursor)

        self.null_count = 0
        self.validity = Bitmap(validity_list)
        self.mem_used = self.value_buffer.mem_used

    fn __getitem__(self, index: Int) raises -> List[Scalar[Self.element_type]]:
        if index < 0 or index >= self.length:
            raise Error("index out of range for FixedSizedList")
        var ret = List[Scalar[Self.element_type]](capacity=self.list_size)
        var offset = Int(self.list_size * index)
        for i in range(self.list_size):
            ret.append(self.value_buffer[offset + i])
        return ret
