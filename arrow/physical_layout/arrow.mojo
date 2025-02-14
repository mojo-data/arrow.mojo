from memory import memset_zero
from arrow.util import ALIGNMENT, get_num_bytes_with_padding
from arrow.buffer.bitmap import Bitmap
from arrow.buffer.offset import OffsetBuffer64
from arrow.buffer.dtype import DTypeBuffer


# struct ArrowFixedWidthVector[T: DType]:
#     # TODO: support null values
#     var length: Int
#     var null_count: Int
#     var validity: Bitmap
#     var _value_buffer: DTypeBuffer[Scalar[T]]

#     var mem_use: Int

#     fn __init__(mut self, values: List[Scalar[T]]) raises:
#         self._value_buffer = DTypeBuffer[Scalar[T]](len(values))

#         var validity_list = List[Bool](len(values))

#         for i in range(values.size):
#             validity_list.append(True)
#             self._value_buffer[i] = values[i]

#         self.validity = Bitmap(validity_list)
#         self.null_count = 0
#         self.length = len(values)
#         self.mem_use = self._value_buffer.mem_used + self.validity.mem_used

#     fn __getitem__(self, index: Int) raises -> T:
#         if index < 0 or index >= self.length:
#             raise Error("index out of range for ArrowFixedWidthVector")
#         return self._value_buffer[index]

#     fn __len__(self) -> Int:
#         return self.length


struct ArrowIntVector:
    """
    Temporary solution until we can create ArrowFixedWidthVector[Int]
    Depends on https://github.com/modularml/mojo/issues/2956 to be fixed.
    """

    var length: Int
    var null_count: Int
    var validity: Bitmap
    var value_buffer: OffsetBuffer64
    var mem_used: Int

    fn __init__(mut self, values: List[Int64]):
        self.length = len(values)
        self.value_buffer = OffsetBuffer64(values)

        var validity_list = List[Bool](capacity=len(values))
        for i in range(values.size):
            validity_list.append(True)
            var val = values[i]
            self.value_buffer._unsafe_setitem(i, val)

        self.validity = Bitmap(validity_list)
        self.null_count = 0

        self.mem_used = self.value_buffer.mem_used + self.validity.mem_used

    fn __getitem__(self, index: Int) raises -> Int64:
        return self.value_buffer[index]

    fn __len__(self) -> Int:
        return self.length
