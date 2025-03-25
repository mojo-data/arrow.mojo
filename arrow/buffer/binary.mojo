from arrow.util import ALIGNMENT, get_num_bytes_with_padding
from memory import memset_zero, UnsafePointer


@value
struct BinaryBuffer:
    alias _ptr_type = UnsafePointer[UInt8, alignment=ALIGNMENT]
    var _buffer: Self._ptr_type
    var length: Int
    var mem_used: Int

    fn __init__(mut self, length_unpadded: Int):
        self.length = length_unpadded
        self.mem_used = get_num_bytes_with_padding(length_unpadded)
        self._buffer = Self._ptr_type.alloc(self.mem_used)
        memset_zero(self._buffer, self.mem_used)

    fn __init__(mut self, values: List[UInt8]):
        self = Self(len(values))
        self._unsafe_set_sequence(0, values)

    @always_inline
    fn _unsafe_setitem(self, index: Int, value: UInt8):
        self._buffer[index] = value

    fn __setitem__(self, index: Int, value: UInt8) raises:
        if index < 0 or index >= self.length:
            raise Error("index out of range for BinaryBuffer")
        self._unsafe_setitem(index, value)

    @always_inline
    fn _unsafe_getitem(self, index: Int) -> UInt8:
        return self._buffer[index]

    fn __getitem__(self, index: Int) raises -> UInt8:
        if index < 0 or index >= self.length:
            raise Error("index out of range for BinaryBuffer")
        return self._unsafe_getitem(index)

    fn _unsafe_set_sequence(self, start: Int, values: List[UInt8]):
        for i in range(len(values)):
            self._unsafe_setitem(start + i, values[i])

    fn set_sequence(self, start: Int, values: List[UInt8]) raises:
        if start < 0 or start + len(values) > self.length:
            raise Error("index out of range for BinaryBuffer")
        self._unsafe_set_sequence(start, values)

    fn _unsafe_get_sequence(self, start: Int, length: Int) -> List[UInt8]:
        """Build a new List of UInt8 from the BinaryBuffer starting at `start` for `length` bytes.""" 

        var values = List[UInt8](capacity=length)
        for i in range(length):
            values.append(self._unsafe_getitem(start + i))
        return values

    fn _unsafe_get_sequence(
        self, start: Int, length: Int, mut bytes: List[UInt8]
    ):
        for i in range(length):
            bytes[i] = self._unsafe_getitem(start + i)

    fn get_sequence(self, start: Int, length: Int) raises -> List[UInt8]:
        if start < 0 or start + length > self.length:
            raise Error("index out of range for BinaryBuffer")
        return self._unsafe_get_sequence(start, length)

    fn __len__(self) -> Int:
        return self.length

    # Lifecycle methods

    fn __moveinit__(mut self, owned existing: BinaryBuffer):
        self._buffer = existing._buffer
        self.length = existing.length
        self.mem_used = existing.mem_used

    fn __copyinit__(mut self, existing: BinaryBuffer):
        self.length = existing.length
        self.mem_used = existing.mem_used
        self._buffer = Self._ptr_type.alloc(self.mem_used)
        for i in range(self.mem_used):
            self._buffer[i] = existing._buffer[i]

    fn __del__(owned self):
        self._buffer.free()
