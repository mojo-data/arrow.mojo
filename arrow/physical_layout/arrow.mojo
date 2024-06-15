from memory.unsafe import Pointer
from memory import memset_zero
from arrow.util import ALIGNMENT, get_num_bytes_with_padding
from arrow.buffer.bitmap import Bitmap
from arrow.buffer.offset import OffsetBuffer


struct ArrowFixedWidthVector[T: AnyTrivialRegType]:
    # TODO: support null values
    var length: Int
    var null_count: Int
    var validity: Bitmap
    var value: Pointer[UInt8]
    var view: Pointer[T]

    var mem_use: Int

    fn __init__(inout self, values: List[T]):
        var byte_width = sizeof[T]()
        var num_bytes = len(values) * byte_width
        var num_bytes_with_padding = get_num_bytes_with_padding(num_bytes)
        var ui8_ptr = Pointer[UInt8].alloc(
            num_bytes_with_padding, alignment=ALIGNMENT
        )
        memset_zero(ui8_ptr, num_bytes_with_padding)
        var ptr = ui8_ptr.bitcast[T]()

        var validity_list = List[Bool](len(values))

        for i in range(values.size):
            validity_list.append(True)
            var val = values[i]
            ptr.store(i, val)

        self.value = ui8_ptr
        self.validity = Bitmap(validity_list)
        self.null_count = 0
        self.view = ptr
        self.length = len(values)
        self.mem_use = num_bytes_with_padding

    fn __getitem__(self, index: Int) raises -> T:
        if index < 0 or index >= self.length:
            raise Error("index out of range for ArrowFixedWidthVector")
        return self.view.load(index)

    fn __len__(self) -> Int:
        return self.length

    fn __del__(owned self):
        self.value.free()


struct ArrowIntVector:
    """
    Temporary solution until we can create ArrowFixedWidthVector[Int]
    Depends on https://github.com/modularml/mojo/issues/2956 to be fixed.
    """

    var length: Int
    var null_count: Int
    var validity: Bitmap
    var value_buffer: OffsetBuffer
    var mem_used: Int

    fn __init__(inout self, values: List[Int]):
        self.length = len(values)
        self.value_buffer = OffsetBuffer(values)

        var validity_list = List[Bool](capacity=len(values))
        for i in range(values.size):
            validity_list.append(True)
            var val = values[i]
            self.value_buffer._unsafe_setitem(i, val)

        self.validity = Bitmap(validity_list)
        self.null_count = 0

        self.mem_used = self.value_buffer.mem_used + self.validity.mem_used

    fn __getitem__(self, index: Int) raises -> Int:
        return self.value_buffer[index]

    fn __len__(self) -> Int:
        return self.length
