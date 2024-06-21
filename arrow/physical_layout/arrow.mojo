from memory.unsafe import Pointer
from memory import memset_zero
from arrow.util import ALIGNMENT, get_num_bytes_with_padding
from arrow.buffer.bitmap import Bitmap
from arrow.buffer.offset import OffsetBuffer64


struct ArrowFixedWidthVector[T: DType]:
    var length: Int
    var null_count: Int
    var validity: Bitmap
    alias _ptr_type = DTypePointer[DType.uint8]
    var value: Self._ptr_type
    var view: DTypePointer[T]

    var mem_used: Int

    fn __init__(inout self, values: List[Scalar[T]]):
        var byte_width = sizeof[T]()
        var num_bytes = len(values) * byte_width
        var num_bytes_with_padding = get_num_bytes_with_padding(num_bytes)
        var ui8_ptr = Self._ptr_type.alloc(
            num_bytes_with_padding, alignment=ALIGNMENT
        )
        memset_zero(ui8_ptr, num_bytes_with_padding)
        var ptr = ui8_ptr.bitcast[T]()

        var validity_list = List[Bool](capacity=len(values))

        for i in range(values.size):
            validity_list.append(True)
            var val = values[i]
            ptr[i] = val

        self.value = ui8_ptr
        self.validity = Bitmap(validity_list)
        self.null_count = 0
        self.view = ptr
        self.length = len(values)
        self.mem_used = num_bytes_with_padding

    fn __init__(inout self, values: List[Optional[Scalar[T]]]):
        var byte_width = sizeof[T]()
        var num_bytes = len(values) * byte_width
        var num_bytes_with_padding = get_num_bytes_with_padding(num_bytes)
        var ui8_ptr = Self._ptr_type.alloc(
            num_bytes_with_padding, alignment=ALIGNMENT
        )
        memset_zero(ui8_ptr, num_bytes_with_padding)
        var ptr = ui8_ptr.bitcast[T]()

        var validity_list = List[Bool](capacity=len(values))

        var null_count = 0

        for i in range(values.size):
            var val = values[i]
            if val:
                validity_list.append(True)
                ptr[i] = val.value()
            else:
                null_count += 1
                validity_list.append(False)
                ptr[i] = 0

        self.value = ui8_ptr
        self.validity = Bitmap(validity_list)
        self.null_count = null_count
        self.view = ptr
        self.length = len(values)
        self.mem_used = num_bytes_with_padding

    fn __getitem__(self, index: Int) -> Optional[Scalar[T]]:
        if not (0 <= index < self.length):
            return None
        if not self.validity[index]:
            return None
        return self.view[index]

    fn unsafe_get(self, index: Int) -> Scalar[T]:
        """Get the value at the index without bounds or validity checking.

        Args:
            index: The index.

        Returns:
            The value.
        """
        return self.view[index]

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
    var value_buffer: OffsetBuffer64
    var mem_used: Int

    fn __init__(inout self, values: List[Int]):
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
